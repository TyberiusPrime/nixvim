{ pkgs, ... }:
{
  extraPlugins = [
    (pkgs.vimUtils.buildVimPlugin {
      name = "nvim-utils";
      src = pkgs.fetchFromGitHub {
        owner = "norcalli";
        repo = "nvim_utils";
        rev = "71919c2f05920ed2f9718b4c2e30f8dd5f167194";
        sha256 = "sha256-lrooNuJOV0gfg+OiKl09Iyn1jMuVXI87vSoZddenwXI=";
      };
    })
  ];

  extraConfigLua = ''
    require("nvim_utils")
    function line_wise_rev_complement(is_visual_mode)
    	local function replace(lines, visualmode)
    		--local lines = nvim.fn.getreg(register, 1, 1)
    		local out = {}
    		for key, value in pairs(lines) do
    			local r = string.reverse(value)
    			local rc = r:gsub("[acgtACGT]", {
    				["A"] = "T",
    				["C"] = "G",
    				["G"] = "C",
    				["T"] = "A",
    				["a"] = "t",
    				["c"] = "g",
    				["g"] = "c",
    				["t"] = "a",
    			})
    			table.insert(out, rc)
    		end
    		return out
    	end
    	if is_visual_mode then
                  local visual_mode = nvim_visual_mode()
                  nvim_buf_transform_region_lines(nil, "<", ">", visual_mode, replace)
    	else
                  nvim_text_operator_transform_selection(replace)
    	end
    end
  '';

  keymaps = [
    # {
    #   action = ":lua line_wise_rev_complement(false)<CR>";
    #   key = "gR";
    #   mode = "n";
    # }
    {
      action = ":lua line_wise_rev_complement(true)<CR>";
      key = "gR";
      mode = "v";
    }
  ];

}
