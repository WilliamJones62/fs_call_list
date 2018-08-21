class DontSellsController < ApplicationController
  before_action :set_dont_sell, only: [:show, :edit, :update, :destroy]

  # GET /dont_sells
  # GET /dont_sells.json
  def index
    @dont_sells = DontSell.all
  end

  # GET /dont_sells/1
  # GET /dont_sells/1.json
  def show
  end

  # GET /dont_sells/new
  def new
    @dont_sell = DontSell.new
  end

  # GET /dont_sells/1/edit
  def edit
  end

  # POST /dont_sells
  # POST /dont_sells.json
  def create
    @dont_sell = DontSell.new(dont_sell_params)

    respond_to do |format|
      if @dont_sell.save
        format.html { redirect_to @dont_sell, notice: 'Dont sell was successfully created.' }
        format.json { render :show, status: :created, location: @dont_sell }
      else
        format.html { render :new }
        format.json { render json: @dont_sell.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /dont_sells/1
  # PATCH/PUT /dont_sells/1.json
  def update
    respond_to do |format|
      if @dont_sell.update(dont_sell_params)
        format.html { redirect_to @dont_sell, notice: 'Dont sell was successfully updated.' }
        format.json { render :show, status: :ok, location: @dont_sell }
      else
        format.html { render :edit }
        format.json { render json: @dont_sell.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /dont_sells/1
  # DELETE /dont_sells/1.json
  def destroy
    @dont_sell.destroy
    respond_to do |format|
      format.html { redirect_to dont_sells_url, notice: 'Dont sell was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_dont_sell
      @dont_sell = DontSell.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def dont_sell_params
      params.require(:dont_sell).permit(:customer, :part, :dontcalls_start, :dontcalls_end)
    end
end
