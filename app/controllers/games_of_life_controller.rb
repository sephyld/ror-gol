class GamesOfLifeController < ApplicationController
end
class GamesOfLifeController < ApplicationController
  before_action :authenticate_user!, except: [ :index ]

  def index
  end

  def post_file_gol
    begin
      file = file_post_params
      handle_file_upload file
    rescue ActionController::ParameterMissing
      @message = "File is required"
      respond_to do |format|
        format.turbo_stream { render "error_msg", status: 406 }
      end
      return
    rescue GameOfLife::FileValidationError => e
      @message = e.message
      respond_to do |format|
        format.turbo_stream { render "error_msg", status: 406 }
      end
      return
    end
    respond_to do |format|
      format.turbo_stream
    end
  end

  def post_random_gol
    @game_state = GameOfLife::GameState.random
    respond_to do |format|
      format.turbo_stream { render "post_file_gol" }
    end
  end

  def post_next_generation
    generation = params[:generation].to_i
    rows = params[:rows].to_i
    columns = params[:columns].to_i
    grid = params[:layed_down_grid].split(";").map do |row|
      row.chars.map { |ch| GameOfLife::Cell.new ch }
    end
    @game_state = GameOfLife::GameState.new generation, rows, columns, grid
    @game_state.next_generation!
    respond_to do |format|
      format.turbo_stream
    end
  end

  private
  def handle_file_upload(file)
    @game_state = GameOfLife::GameState.new file.tempfile
  end

  def file_post_params
    params.require(:state_file)
  end
end
