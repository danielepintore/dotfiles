return {
    uwsm = function(cmd)
        assert(cmd, "uwsm() -> cmd is required")
        return "uwsm-app -- " .. cmd
    end,
    noctalia_ipc = function(cmd)
        assert(cmd, "noctalia_ipc() -> cmd is required")
        return "qs -c noctalia-shell ipc call " .. cmd
    end
}
