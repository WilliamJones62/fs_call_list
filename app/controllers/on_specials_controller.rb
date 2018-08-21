class OnSpecialsController < ApplicationController
  before_action :set_on_special, only: [:show, :edit, :update, :destroy]

  # GET /on_specials
  # GET /on_specials.json
  def index
    @on_specials = OnSpecial.all
  end

  # GET /on_specials/1
  # GET /on_specials/1.json
  def show
  end

  # GET /on_specials/new
  def new
    @on_special = OnSpecial.new
  end

  # GET /on_specials/1/edit
  def edit
  end

  # POST /on_specials
  # POST /on_specials.json
  def create
    @on_special = OnSpecial.new(on_special_params)

    respond_to do |format|
      if @on_special.save
        format.html { redirect_to @on_special, notice: 'On special was successfully created.' }
        format.json { render :show, status: :created, location: @on_special }
      else
        format.html { render :new }
        format.json { render json: @on_special.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /on_specials/1
  # PATCH/PUT /on_specials/1.json
  def update
    respond_to do |format|
      if @on_special.update(on_special_params)
        format.html { redirect_to @on_special, notice: 'On special was successfully updated.' }
        format.json { render :show, status: :ok, location: @on_special }
      else
        format.html { render :edit }
        format.json { render json: @on_special.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /on_specials/1
  # DELETE /on_specials/1.json
  def destroy
    @on_special.destroy
    respond_to do |format|
      format.html { redirect_to on_specials_url, notice: 'On special was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_on_special
      @on_special = OnSpecial.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def on_special_params
      params.require(:on_special).permit(:customer, :part, :onspecials_start, :onspecials_end)
    end
end
