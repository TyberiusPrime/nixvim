{ ... }:
{
  plugins.snacks = {
    enable = true;
    settings = {
      picker.enable = true;
      picker.settings = {
        ui_select = true;
      };
      bigfile.enable = true;
      indent = {
        enable = true;
        animate.enabled = false;
      };
      # image = {
      #   enable = false;
      # };
    };
  };

  extraConfigLua = ''
    -- snacks.image locates images with treesitter `images` queries, so it only
    -- ever sees them in the handful of languages it ships a query for --
    -- markdown and typst yes, asciidoc no (nvim-treesitter has no asciidoc
    -- grammar at all), plain text obviously no. Hand it the matches ourselves
    -- for everything it does not already understand.

    local IMAGE_EXT = {
      png = true, jpg = true, jpeg = true, gif = true, webp = true,
      svg = true, bmp = true, avif = true, ico = true, tiff = true, tif = true,
    }

    local function line_range(buf, opts)
      local from = math.max((opts and opts.from or 1) - 1, 0)
      return from, vim.api.nvim_buf_get_lines(buf, from, (opts and opts.to) or -1, false)
    end

    local function match(buf, lnum, first, last, src)
      return {
        id = ("snacks-img:%d:%d"):format(lnum, first),
        src = require("snacks.image.doc").resolve(buf, src),
        lang = vim.bo[buf].filetype,
        type = "image",
        range = { lnum, first - 1, lnum, last },
        pos = { lnum, first - 1 },
      }
    end

    -- `image::foo.png[]` and the inline `image:foo.png[]`
    local function asciidoc_images(buf, opts)
      local from, lines = line_range(buf, opts)
      local matches = {}
      for i, line in ipairs(lines) do
        local lnum, pos = from + i, 1
        while true do
          local s, e, src = line:find("image::?([^%[%]%s]+)%[[^%]]*%]", pos)
          if not s then
            break
          end
          -- a macro, not the tail of `not-an-image::foo[]`
          if s == 1 or not line:sub(s - 1, s - 1):match("[%w_%-%.:]") then
            matches[#matches + 1] = match(buf, lnum, s, e, src)
          end
          pos = e + 1
        end
      end
      return matches
    end

    -- Anything that looks like a path to an image file and actually is one.
    -- This is what makes hover work on the bare `./<hash>.png` that img-clip
    -- inserts in a buffer with no markup language to speak of.
    local function bare_path_images(buf, opts)
      local from, lines = line_range(buf, opts)
      local matches = {}
      for i, line in ipairs(lines) do
        local lnum, pos = from + i, 1
        while true do
          local s, e, token = line:find("([%w%._%-~/\\]+)", pos)
          if not s then
            break
          end
          pos = e + 1
          local ext = token:match("%.([%a%d]+)$")
          if ext and IMAGE_EXT[ext:lower()] then
            local m = match(buf, lnum, s, e, token)
            -- only if it resolved to a file that is really there, so we do not
            -- pop a window open on every mention of foo.png in prose
            if vim.fn.filereadable(m.src) == 1 then
              matches[#matches + 1] = m
            end
          end
        end
      end
      return matches
    end

    -- does snacks ship an `images` query for this buffer's language?
    local function snacks_handles(buf)
      local lang = vim.treesitter.language.get_lang(vim.bo[buf].filetype)
      return lang ~= nil and vim.tbl_contains(require("snacks").image.langs(), lang)
    end

    local patched = false
    function image_hover()
      if not patched then
        patched = true
        local doc = require("snacks.image.doc")
        local find = doc.find
        doc.find = function(buf, cb, opts)
          if vim.bo[buf].filetype == "asciidoc" then
            return cb(asciidoc_images(buf, opts))
          end
          if snacks_handles(buf) then
            return find(buf, cb, opts) -- markdown, typst, html, ... unchanged
          end
          return cb(bare_path_images(buf, opts))
        end
      end
      require("snacks").image.hover()
    end
  '';

  keymaps = [
    {
      action = ":lua image_hover()<cr>";
      key = "<leader>i";
      mode = "n";
    }
  ];
}
