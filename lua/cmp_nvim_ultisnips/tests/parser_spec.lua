local parser = require('cmp_nvim_ultisnips.parser')

describe('parser for grammar', function()
  describe('with terminal symbol', function()
    it('should match second rule if first one failed', function()
      local productions = {
        S = {
          rhs = { '^%a+', '^%d+'}
        }
      }
      local grammar = { start_symbol = 'S', productions = productions }
      local result = parser.parse('123 test', grammar, false)
      assert.is_not_nil(result)
      local expected = { matches = { '123' }, remaining = ' test' }
      assert.are_same(expected, result)
    end)

    it('should match description regex', function()
      local productions = {
        S = {
          rhs = { '^"[^"]+"' }
        }
      }
      local grammar = { start_symbol = 'S', productions = productions }
      local result = parser.parse('"some description"', grammar, false)
      assert.is_not_nil(result)
      local expected = { matches = { '"some description"' }, remaining = '' }
      assert.are_same(expected, result)
    end)

    it('should not match', function()
      local productions = {
        S = {
          rhs = { '^%d+'}
        }
      }
      local grammar = { start_symbol = 'S', productions = productions }
      assert.is_nil(parser.parse('test 123', grammar))
    end)

    it('should match based on result of verify function', function()
      local productions = {
        S = {
          rhs = { '^%S+' },
          verify_matches = function(_, matches)
            -- only match when first char is 'x'
            return matches[1]:sub(1, 1) == 'x'
          end
        }
      }
      local grammar = { start_symbol = 'S', productions = productions }
      local actual = parser.parse('xyz', grammar)
      assert.is_not_nil(actual)
      local expected = { matches = { 'xyz' }, remaining = '' }
      assert.are_same(expected, actual)

      -- failure case
      assert.is_nil(parser.parse('zyx', grammar))
    end)

    it('should provide captured values in verify function and result table', function()
      local captured_rules = {}
      local captured_matches = {}

      local productions = {
        S = {
          rhs = { '^X(.*)X', '^M(.*)M A' },
          verify_matches = function(rule, matches)
            table.insert(captured_rules, rule)
            table.insert(captured_matches, matches)
            return true
          end
        },
        A = {
          rhs = { 'a' }
        }
      }
      local grammar = { start_symbol = 'S', productions = productions }
      local actual = parser.parse('Msome str1ngsM arest', grammar, false)

      -- one call to verify for the applied rule
      assert.are_same({ '^M(.*)M A' }, captured_rules)
      assert.are_same({ { 'some str1ngs', 'a' } }, captured_matches)

      assert.is_not_nil(actual)
      local expected = { matches = { 'some str1ngs', 'a' }, remaining = 'rest' }
      assert.are_same(expected, actual)
    end)

    it('should match based on result of verify function (more complex test)', function()
      local productions = {
        S = {
          rhs = { '^.*' },
          verify_matches = function(_, matches)
            -- only match when surrounding chars are '!'
            local valid = matches[1]:sub(1, 1) == '!' and matches[1]:sub(-1, -1) == '!'
            -- it is possible to change the captured value since captures are passed by reference
            if valid == true then
              matches[1] = matches[1]:sub(2, -2)
            end
            return valid
          end
        }
      }
      local grammar = { start_symbol = 'S', productions = productions }
      local actual = parser.parse('!test!', grammar)
      assert.is_not_nil(actual)
      local expected = { matches = { 'test' }, remaining = '' }
      assert.are_same(expected, actual)
    end)

    it('should provide matches in on_store_matches when verify succeeded', function()
      local captured_symbols = {}
      local captured_matches = {}
      local productions = {
        S = {
          rhs = { 'A C', 'B C' },
          verify_matches = function(rule, _)
            -- only allow second rule
            return rule == 'B C'
          end,
          on_store_matches = function(symbols, matches)
            table.insert(captured_symbols, symbols)
            table.insert(captured_matches, matches)
          end
        },
        A = {
          rhs = { 'a' }
        },
        B = {
          rhs = { 'a' }
        },
        C = {
          rhs = { 'c' }
        }
      }
      local grammar = { start_symbol = 'S', productions = productions }
      local actual = parser.parse('ac', grammar)

      assert.are_same({ { 'B', 'C' } }, captured_symbols)
      assert.are_same({ { 'a', 'c' } }, captured_matches)

      assert.is_not_nil(actual)
      local expected = { matches = { 'a', 'c' }, remaining = '' }
      assert.are_same(expected, actual)
    end)
  end)

  describe('with non-terminal symbol', function()
    it('should match', function()
      local productions = {
        S = { rhs = { 'A D' } },
        A = { rhs = { 'B C' } },
        B = { rhs = { '^b' } },
        C = { rhs = { '^c' } },
        D = { rhs = { '^d' } }
      }
      local grammar = { start_symbol = 'S', productions = productions }
      local expected = {
        matches = {
          { 'b', 'c' }, -- matched by non-terminal A
          'd' -- matched by non-terminal D
        },
        remaining = 'rest'
      }
      local actual = parser.parse('bcdrest', grammar)
      assert.is_not_nil(actual)
      assert.are_same(expected, actual)
    end)

    it('should not match when last non-terminal fails', function()
      local productions = {
        S = { rhs = { 'A D' } },
        A = { rhs = { 'B C' } },
        B = { rhs = { '^b' } },
        C = { rhs = { '^c' } },
        D = { rhs = { '^d' } }
      }
      local grammar = { start_symbol = 'S', productions = productions }
      assert.is_nil(parser.parse('bc!rest', grammar))
    end)
  end)
end)

describe('parser for', function()
  describe('snippet header', function()
    it('should match tab_trigger including quotes when no r option or multiword trigger', function()
      local result = parser.parse_snippet_header('"snip"')
      local expected = {
        tab_trigger = '"snip"'
      }
      assert.are_same(expected, result)
    end)

    it('should match multiword tab-trigger surrounded with "!"', function()
      local result = parser.parse_snippet_header('!"some" trigger! "a description"')
      local expected = {
        description = 'a description',
        tab_trigger = '"some" trigger'
      }
      assert.are_same(expected, result)
    end)

    it('should match quoted tab_trigger, description, options', function()
      local result = parser.parse_snippet_header('"tab - trigger"  "some description"   options')
      local expected = {
        options = 'options',
        description = 'some description',
        tab_trigger = 'tab - trigger'
      }
      assert.are_same(expected, result)
    end)

    it('should remove surrounding from tab_trigger when regex option is provided', function()
      local result = parser.parse_snippet_header('|^(foo|bar)$| "" r')
      local expected = {
        options = 'r',
        description = '',
        tab_trigger = '^(foo|bar)$'
      }
      assert.are_same(expected, result)
    end)

    it('should not remove surrounding from tab_trigger when regex option is not provided', function()
      local result = parser.parse_snippet_header('|^(foo|bar)$| "" ba')
      local expected = {
        options = 'ba',
        description = '',
        -- keep surrounding '|'
        tab_trigger = '|^(foo|bar)$|'
      }
      assert.are_same(expected, result)
    end)

    it('should match options with "!"', function()
      local result = parser.parse_snippet_header('test "description" b!')
      local expected = {
        options = 'b!',
        description = 'description',
        tab_trigger = 'test'
      }
      assert.are_same(expected, result)
    end)

    it('should match options with expression', function()
      local result = parser.parse_snippet_header('trigger "d" "expr" be')
      local expected = {
        options = 'be',
        expression = 'expr',
        description = 'd',
        tab_trigger = 'trigger'
      }
      assert.are_same(expected, result)
      -- failure case
      assert.are_same({}, parser.parse_snippet_header('trigger "d" "expr" br'))
    end)

    it('should not match invalid multiword tab-trigger', function()
      local result = parser.parse_snippet_header('invalid multiword-trigger "description"')
      assert.are_same({}, result)
    end)

    it('should not cause exception for snippet with trailing spaces (#23)', function()
      local result = parser.parse_snippet_header('func "Function Header" ')
      assert.are_same({}, result)
    end)

    it('should match tab-trigger containing dot', function()
      local result = parser.parse_snippet_header('j.u')
      local expected = {
        tab_trigger = 'j.u'
      }
      assert.are_same(expected, result)
    end)

    it('should match tab_trigger with less than 3 chars', function()
      local result = parser.parse_snippet_header('c "Constructor" b')
      local expected = {
        tab_trigger = 'c',
        description = 'Constructor',
        options = 'b'
      }
      assert.are_same(expected, result)
    end)

  end)
end)
