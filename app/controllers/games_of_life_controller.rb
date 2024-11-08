class GamesOfLifeController < ApplicationController
  before_action :authenticate_user!, except: [ :index ]

  def index
  end

  def post_file_gol
    file = handle_file_read
    return if file == false
    return if handle_file_upload_error(file) == false
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
    @game_state.custom_pretty_print
  end

  def handle_file_read
    begin
      file = file_post_params
    rescue ActionController::ParameterMissing
      @message = "File is required"
      respond_to do |format|
        format.turbo_stream { render "error_msg" }
      end
      return false
    end
    file
  end

  def handle_file_upload_error(file)
    begin
      handle_file_upload file
    rescue GameOfLife::FileValidationError => e
      @message = e.message
      respond_to do |format|
        format.turbo_stream { render "error_msg" }
      end
      return false
    end
    true
  end

  def file_post_params
    params.require(:state_file)
  end
end
