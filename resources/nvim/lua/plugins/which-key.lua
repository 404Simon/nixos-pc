return {
  {
    'folke/which-key.nvim',
    event = 'VimEnter',
    config = function ()
      local w = require('which-key')
      w.setup {
        preset = 'helix',
      }
      w.add {
        { '<leader>?', '<cmd>WhichKey<cr>', desc = 'Show All Keybindings', mode = 'n' },
      }
    end
 },
}
