class IsrListsController < ApplicationController
  before_action :set_isr_list, only: [:show, :edit, :update, :destroy]

  # GET /isr_lists
  # GET /isr_lists.json
  def index
    @isr_lists = IsrList.all
  end

  # GET /isr_lists/1
  # GET /isr_lists/1.json
  def show
  end

  # GET /isr_lists/new
  def new
    @isr_list = IsrList.new
  end

  # GET /isr_lists/1/edit
  def edit
  end

  # POST /isr_lists
  # POST /isr_lists.json
  def create
    @isr_list = IsrList.new(isr_list_params)

    respond_to do |format|
      if @isr_list.save
        format.html { redirect_to @isr_list, notice: 'ISR list was successfully created.' }
        format.json { render :show, status: :created, location: @isr_list }
      else
        format.html { render :new }
        format.json { render json: @isr_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /isr_lists/1
  # PATCH/PUT /isr_lists/1.json
  def update
    respond_to do |format|
      if @isr_list.update(isr_list_params)
        format.html { redirect_to @isr_list, notice: 'ISR list was successfully updated.' }
        format.json { render :show, status: :ok, location: @isr_list }
      else
        format.html { render :edit }
        format.json { render json: @isr_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /isr_lists/1
  # DELETE /isr_lists/1.json
  def destroy
    @isr_list.destroy
    respond_to do |format|
      format.html { redirect_to isr_lists_url, notice: 'ISR list was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_isr_list
      @isr_list = IsrList.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def isr_list_params
      params.require(:isr_list).permit(:name)
    end
end
