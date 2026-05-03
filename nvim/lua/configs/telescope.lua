local actions = require("telescope.actions")

return {
    defaults = {
        prompt_prefix = "   ",
        selection_caret = "  ",
        entry_prefix = "  ",
        sorting_strategy = "ascending",
        layout_config = {
            horizontal = {
                prompt_position = "top",
                preview_width = 0.55,
            },
            width = 0.87,
            height = 0.8,
        },
        mappings = {
            n = { ["q"] = actions.close },
        },
    },
}
