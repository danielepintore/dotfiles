return {
    uwsm = function(cmd)
        assert(cmd, "uwsm() -> cmd is required")
        return "uwsm-app -- " .. cmd
    end,
}
