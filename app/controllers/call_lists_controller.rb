class CallListsController < ApplicationController
  before_action :set_call_list, only: [:show, :edit, :update, :destroy]
  before_action :build_lists, only: [:new, :edit]
  before_action :load_rep, only: [:create, :update]

  # GET /call_lists
  def index
    call_lists = CallList.all
    @call_lists = []
    if current_user.email == 'admin'
      @call_lists = call_lists
    else
      call_lists.each do |c|
        if c.rep == current_user.email.upcase
          @call_lists.push(c)
        end
      end
    end
  end

  # GET /call_lists/1
  def show
  end

  # GET /call_lists/new
  def new
    @call_list = CallList.new
  end

  # GET /call_lists/1/edit
  def edit
  end

  # POST /call_lists
  def create
    @call_list = CallList.new(@cp)

    respond_to do |format|
      if @call_list.save
        format.html { redirect_to @call_list, notice: 'Call list was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /call_lists/1
  def update
    respond_to do |format|
      if @call_list.update(@cp)
        format.html { redirect_to @call_list, notice: 'Call list was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /call_lists/1
  def destroy
    @call_list.destroy
    respond_to do |format|
      format.html { redirect_to call_lists_url, notice: 'Call list was successfully destroyed.' }
    end
  end

  def import
    CallList.import(params[:file])
    redirect_to root_url, notice: "Call list imported."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_call_list
      @call_list = CallList.find(params[:id])
    end

    # Add sales data to parameters
    def load_rep
      @cp = call_list_params
      @cp[:rep] = current_user.email
    end

    # Use callbacks to share common setup or constraints between actions.
    def build_lists
      @callday = ['SUNDAY', 'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY']
      @callback = [' ', 'SUNDAY', 'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY']
      @contact_method = ['CALL', 'EMAIL', 'TEXT']
      @called = ['NO', 'NO ANSWER', 'YES']
      @ordered = [' ', 'NO', 'YES']
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def call_list_params
      params.require(:call_list).permit(:custcode, :custname, :contact_method, :callday, :notes, :contact, :phone, :email, :selling, :main_phone, :website, :rep, :isr, :called, :date_called, :ordered, :date_ordered, :callback, :callback_date)
    end
end
