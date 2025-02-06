local M = {}

local default_opts = {
    connections = {
        ssh_configs = {
            vim.fn.expand "$HOME" .. "/.ssh/config",
            "/etc/ssh/ssh_config",
            -- "/path/to/custom/ssh_config"
        },
        sshfs_args = {
            "-o reconnect",
            "-o ConnectTimeout=5",
        },
    },
    mounts = {
        base_dir = vim.fn.expand "$HOME" .. "/.sshfs/",
        unmount_on_exit = false,
    },
    handlers = {
        on_connect = {
            change_dir = true,
        },
        on_disconnect = {
            clean_mount_folders = false,
        },
        on_add = {},
        on_edit = {},
    },
    ui = {
        select_prompts = false, -- not yet implemented
        confirm = {
            connect = true,
            change_dir = false,
        },
    },
    log = {
        enable = false,
        truncate = false,
        types = {
            all = true,
            util = false,
            handler = false,
            sshfs = false,
        },
    },
}

M.setup_commands = function()
    -- Create commands to connect/edit/reload/disconnect/find_files/live_grep
    vim.api.nvim_create_user_command("RemoteSSHConnect", function(opts)
        if opts.args and opts.args ~= "" then
            local host = require("remote-ssh.utils").parse_host_from_command(opts.args)
            require("remote-ssh.connections").connect(host)
        else
            require("telescope").extensions["remote-ssh"].connect()
        end
    end, { nargs = "?", desc = "Remotely connect to host via picker or command as argument." })
    vim.api.nvim_create_user_command("RemoteSSHEdit", function()
        require("telescope").extensions["remote-ssh"].edit()
    end, {})
    vim.api.nvim_create_user_command("RemoteSSHReload", function()
        require("remote-ssh.connections").reload()
    end, {})
    vim.api.nvim_create_user_command("RemoteSSHDisconnect", function()
        require("remote-ssh.connections").unmount_host()
    end, {})
    vim.api.nvim_create_user_command("RemoteSSHFindFiles", function()
        require("telescope").extensions["remote-ssh"].find_files {}
    end, {})
    vim.api.nvim_create_user_command("RemoteSSHLiveGrep", function()
        require("telescope").extensions["remote-ssh"].live_grep {}
    end, {})
end

M.setup = function(config)
    local opts = config and vim.tbl_deep_extend("force", default_opts, config) or default_opts

    require("remote-ssh.connections").setup(opts)
    require("remote-ssh.ui").setup(opts)
    require("remote-ssh.handler").setup(opts)
    require("remote-ssh.log").setup(opts)

    M.setup_commands()
end

return M
