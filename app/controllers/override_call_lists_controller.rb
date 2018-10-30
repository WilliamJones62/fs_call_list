class OverrideCallListsController < ApplicationController
  before_action :set_override_call_list, only: [:show, :edit, :update, :destroy]

  # GET /override_call_lists
  def index
    @override_call_lists = OverrideCallList.all
  end

  # GET /override_call_lists/1
  def show
  end

  # GET /override_call_lists/new
  def new
    @override_call_list = OverrideCallList.new
  end

  # GET /override_call_lists/1/edit
  def edit
  end

  # POST /override_call_lists
  def create
    respond_to do |format|
      if @override_call_list.save
        format.html { redirect_to @override_call_list, notice: 'Override call list was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /override_call_lists/1
  def update
    @override_call_list = OverrideCallList.find(params[:id])
    if @override_call_list.update(override_call_list_params)
      redirect_to call_lists_path, notice: 'Override call list was successfully updated.'
    else
      render :change
    end
  end

  # DELETE /override_call_lists/1
  def destroy
    @override_call_list.destroy
    respond_to do |format|
      format.html { redirect_to override_call_lists_url, notice: 'Override call list was successfully destroyed.' }
    end
  end

  def change
    @override_call_list = OverrideCallList.find_by(custcode: params[:custcode])
    today = Date.today
    if @override_call_list.override_end < today
      # The override has lapsed so overwrite it with valuse from the base records
      call_list = CallList.find_by(custcode: params[:custcode])
      @override_call_list.custcode = call_list.custcode
      @override_call_list.custname = call_list.custname
      @override_call_list.contact_method = call_list.contact_method
      @override_call_list.contact = call_list.contact
      @override_call_list.phone = call_list.phone
      @override_call_list.email = call_list.email
      @override_call_list.selling = call_list.selling
      @override_call_list.main_phone = call_list.main_phone
      @override_call_list.website = call_list.website
      @override_call_list.rep = call_list.rep
    end

    @callday = ['SUNDAY', 'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY']
    @callback = [' ', 'SUNDAY', 'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY']
    @contact_method = ['CALL', 'EMAIL', 'TEXT']
    @called = ['NO', 'NO ANSWER', 'YES']
    @ordered = [' ', 'NO', 'YES']
    @windows = ['10am - noon', 'noon - 2pm', '2pm - 4pm', '4pm - 6pm']
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_override_call_list
      @override_call_list = OverrideCallList.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def override_call_list_params
      params.require(:override_call_list).permit(:custcode, :custname, :contact_method, :contact, :phone, :email, :selling, :main_phone, :website, :rep, :override_start, :override_end)
    end
end
