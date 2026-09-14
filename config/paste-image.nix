{ pkgs, ... }:
{
  extraPackages = with pkgs; [
    wl-clipboard # wl-paste, wayland
    xclip # x11
    imagemagick # anything -> png
    coreutils # sha256sum
    curl # urls, in the menu variant
  ];

  plugins.img-clip = {
    enable = true;
    settings = {
      default = {
        extension = "png";
        copy_images = true;
        relative_to_current_file = true; # dir_path is relative to the buffer
        use_absolute_path = false;
        relative_template_path = true; # and so is the inserted link
        prompt_for_file_name = false; # the hash is the name
        insert_mode_after_paste = true; # land in the alt text slot
        # closures, so the lookup happens at paste time rather than at setup time,
        # when these globals are not defined yet
        dir_path.__raw = "function(...) return img_dir_path(...) end";
        file_name.__raw = "function(...) return img_file_name(...) end";
      };
      filetypes = {
        # markdown keeps the plugin default: ![$CURSOR]($FILE_PATH)
        # block macro, which is right because img-clip always puts linewise
        asciidoc.template = "image::$FILE_PATH[$CURSOR]";
        # like the default, minus the <fig-...> label, which would just be
        # the content hash and is useless to refer to
        typst.template = ''
          #figure(
            image("$FILE_PATH", width: 80%),
            caption: [$CURSOR],
          )
        '';
      };
    };
  };

  extraConfigLua = ''
    -- Image pasting. Everything funnels through a temp png, so the name we
    -- store under can always be the sha256 of the bytes we actually write.

    -- nil when there is no local clipboard (over ssh), which is what makes
    -- the whole thing degrade to a plain text paste by itself.
    local function clip_tool()
      if vim.env.WAYLAND_DISPLAY ~= nil and vim.env.WAYLAND_DISPLAY ~= "" and vim.fn.executable("wl-paste") == 1 then
        return "wl"
      end
      if vim.env.DISPLAY ~= nil and vim.env.DISPLAY ~= "" and vim.fn.executable("xclip") == 1 then
        return "x"
      end
      return nil
    end

    local function clip_types()
      local tool = clip_tool()
      if not tool then
        return {}
      end
      local cmd = tool == "wl" and { "wl-paste", "--list-types" }
        or { "xclip", "-selection", "clipboard", "-t", "TARGETS", "-o" }
      local out = vim.fn.systemlist(cmd)
      if vim.v.shell_error ~= 0 then
        return {}
      end
      return out
    end

    -- Which mime type to pull an image out of, png preferred, any other
    -- image/* accepted (magick turns it into one). nil means the clipboard
    -- holds no image -- text, a path, a url and empty all land here.
    local function clip_image_mime()
      local fallback = nil
      for _, t in ipairs(clip_types()) do
        t = vim.trim(t)
        if t == "image/png" then
          return t
        end
        if fallback == nil and t:match("^image/") then
          fallback = t
        end
      end
      return fallback
    end

    local function clip_read_cmd(mime)
      if clip_tool() == "wl" then
        return "wl-paste --type " .. vim.fn.shellescape(mime)
      end
      return "xclip -selection clipboard -t " .. vim.fn.shellescape(mime) .. " -o"
    end

    local function clip_text()
      local tool = clip_tool()
      if not tool then
        return ""
      end
      local cmd = tool == "wl" and { "wl-paste", "--no-newline" }
        or { "xclip", "-selection", "clipboard", "-o" }
      local out = vim.fn.systemlist(cmd)
      if vim.v.shell_error ~= 0 then
        return ""
      end
      return vim.trim(table.concat(out, "\n"))
    end

    -- producer is a shell command writing image bytes to stdout. -strip keeps
    -- the hash stable across sources that differ only in metadata.
    local function to_tmp_png(producer)
      local tmp = vim.fn.tempname() .. ".png"
      vim.fn.system({ "sh", "-c", producer .. " | magick - -strip " .. vim.fn.shellescape("png:" .. tmp) })
      if vim.v.shell_error ~= 0 or vim.fn.getfsize(tmp) <= 0 then
        vim.fn.delete(tmp)
        return nil
      end
      return tmp
    end

    -- For notes named `1234-title.adoc` the images go in the sibling `1234/`,
    -- everything else keeps them next to the file.
    function img_dir_path()
      local num = vim.fn.expand("%:t"):match("^(%d+)%-.*%.adoc$")
      return num or "."
    end

    -- Name the file after its content, so pasting the same screenshot twice
    -- overwrites one file instead of making a second copy. The timestamp is
    -- only reached on paths that bypass the wrappers below (drag and drop).
    function img_file_name()
      local src = _G.img_paste_src
      if src and vim.fn.filereadable(src) == 1 then
        local out = vim.fn.system({ "sha256sum", src })
        if vim.v.shell_error == 0 then
          return out:sub(1, 16)
        end
      end
      return "%Y-%m-%d-%H-%M-%S"
    end

    local function insert_tmp(tmp)
      _G.img_paste_src = tmp
      local ok = require("img-clip").paste_image(nil, tmp)
      _G.img_paste_src = nil
      vim.fn.delete(tmp)
      return ok
    end

    -- Image *bytes* in the clipboard, nothing else. A path in the clipboard is
    -- text and stays text -- that is what keeps <c-v> honest.
    function img_paste_clipboard()
      local mime = clip_image_mime()
      if not mime then
        return false
      end
      local tmp = to_tmp_png(clip_read_cmd(mime))
      if not tmp then
        vim.notify("clipboard holds " .. mime .. ", but it could not be converted to png", vim.log.levels.WARN)
        return false
      end
      return insert_tmp(tmp)
    end

    -- The menu variant: image bytes, or a path or url sitting in the
    -- clipboard as text.
    function img_paste_anything()
      if img_paste_clipboard() then
        return true
      end
      if not clip_tool() then
        vim.notify("no local clipboard (ssh?)", vim.log.levels.WARN)
        return false
      end

      local txt = clip_text()
      if txt == "" then
        vim.notify("clipboard is empty", vim.log.levels.WARN)
        return false
      end

      local producer = nil
      if txt:match("^https?://%S+$") then
        producer = "curl -fsSL " .. vim.fn.shellescape(txt)
      else
        local path = vim.fs.normalize((txt:gsub("^file://", "")))
        if vim.fn.filereadable(path) == 1 then
          producer = "cat " .. vim.fn.shellescape(path)
        end
      end
      if not producer then
        vim.notify("clipboard holds no image, readable path or url", vim.log.levels.WARN)
        return false
      end

      local tmp = to_tmp_png(producer)
      if not tmp then
        vim.notify("could not turn the clipboard contents into a png", vim.log.levels.WARN)
        return false
      end
      return insert_tmp(tmp)
    end

    -- <c-v>. The mappings do the `<C-g>u` undo break and drop to normal mode
    -- first, exactly as they did before, so the text path is unchanged.
    function paste_image_or_register()
      if img_paste_clipboard() then
        return
      end
      vim.cmd('normal! "+p')
    end
  '';
}
