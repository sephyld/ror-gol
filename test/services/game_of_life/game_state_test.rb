# test/services/dice_roller_test.rb
require "test_helper"
module GameOfLife
  class GameStateTest < ActiveSupport::TestCase
    test "File parsing error" do
      File.open(Rails.root.join("test", "fixtures", "files", "not_ok_state.txt")) do |file|
        assert_raises(FileValidationError) do
          GameState.new file
        end
      end
    end

    test "File parsed successfully" do
      File.open(Rails.root.join("test", "fixtures", "files", "ok_state_expect_horizontal.txt")) do |file|
        game_state = GameState.new file
        g, r, c = game_state.generation, game_state.rows, game_state.columns
        assert_equal(3, g)
        assert_equal(4, r)
        assert_equal(8, c)
      end
    end

    test "File parsed successfully and next generation call is fine" do
      File.open(Rails.root.join("test", "fixtures", "files", "ok_state_expect_horizontal.txt")) do |file|
        game_state = GameState.new file
        g, r, c = game_state.generation, game_state.rows, game_state.columns
        game_state.next_generation!
        assert_equal(game_state.generation, g + 1)
        assert_equal(game_state.rows, r)
        assert_equal(game_state.columns, c)
        expected_grid = [
          "........".chars,
          "........".chars,
          "...***..".chars,
          "........".chars
        ]
        game_state.grid.each_with_index do |row, i|
          row.each_with_index do |cell, j|
            assert(cell.kind_of? Cell)
            assert_equal(cell.state, expected_grid[i][j])
          end
        end
      end
    end
  end
end
