class CallListsController < ApplicationController
  before_action :set_call_list, only: [:show, :edit, :update, :destroy]
  before_action :build_lists, only: [:new, :edit]
  before_action :load_rep, only: [:create, :update]
  before_action :reset_called_flag, only: [:index]
  before_action :build_call_list, only: [:index]

  # GET /call_lists
  def index
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
    if call_list_params[:callback] && @call_list.callback != call_list_params[:callback]
      @cp[:callback_date] = Date.today
      @cp[:called] = 'NO'
    end
    if call_list_params[:called] && @call_list.called != call_list_params[:called]
      @cp[:date_called] = Date.today
    end
    if call_list_params[:ordered] && @call_list.ordered != call_list_params[:ordered]
      @cp[:date_ordered] = Date.today
    end
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

  def selected
    days = []
    days = session[:calllist_days]
    windows = []
    windows = session[:calllist_windows]
    days.each do |c|
      select_item = []
      select_item = c
      if params[:called_day] == select_item[1].to_s
        session[:called_day] = select_item[0]
        break
      end
    end
    windows.each do |c|
      select_item = []
      select_item = c
      if params[:called_window] == select_item[1].to_s
        session[:called_window] = select_item[0]
        break
      end
    end
    redirect_to action: "index"
  end

  def import
    CallList.import(params[:file])
    redirect_to root_url, notice: "Call list imported."
  end

  def not_called
    @report_list = CallList.where(rep: current_user.email).to_a
  end

  def not_ordered
    @report_list = CallList.where(rep: current_user.email).to_a
  end

  def not_on_list
    list = CallList.where(rep: current_user.email).to_a
    call_list = list.sort_by{ |t| t.custcode }
    list = ActiveCustomer.where(rep: current_user.email).to_a
    active_customer = list.sort_by{ |t| t.custcode }
    @missing_call_list = []
    @user = current_user.email
    custcode = ' '
    i = 0
    active_customer.each do |a|
      if call_list[i].custcode > a.custcode
        # no call list record for this active customer
        if custcode != a.custcode
          # unless there are multiple ship tos for the same customer
          @missing_call_list.push(a)
        end
      elsif call_list[i].custcode == a.custcode
        # only go to the next call list
        custcode = a.custcode
        i += 1
      else
        i += 1
      end
    end
  end

  def no_customer
    list = CallList.where(rep: current_user.email).to_a
    call_list = list.sort_by{ |t| t.custcode }
    list = ActiveCustomer.where(rep: current_user.email).to_a
    active_customer = list.sort_by{ |t| t.custcode }
    @missing_customer = []
    @user = current_user.email
    i = 0
    list_length = call_list.length
    active_customer.each do |a|
      if i < list_length
        if call_list[i].custcode < a.custcode
        # no active customer for this call list record
          @missing_customer.push(call_list[i])
          i += 1
        else call_list[i].custcode == a.custcode
          i += 1
        end
      else
        break
      end
    end
  end

  def all_customer
    @report_list = []
    customer_list = ActiveCustomer.where(rep: current_user.email).to_a
    report_list = customer_list.sort_by{ |t| t.custcode }
    customer = report_list[report_list.length - 1]
    report_list.each do |r|
      if r.custcode != customer.custcode
        @report_list.push(r)
      end
      customer = r
    end
    @call_list = []
    @found = false
    @report_list.each do |r|
      if CallList.exists?(custcode: r.custcode)
        call_exists = CallList.find_by(custcode: r.custcode)
        @call_list.push(call_exists)
      end
    end
  end

  def list
    call_lists = CallList.all
    if !session[:called_isr] || session[:called_isr] == ''
      session[:called_isr] = 'HAYDEN'
    end
    @isr = session[:called_isr]
    @user = current_user.email
    $sunday_list = []
    $monday_list = []
    $tuesday_list = []
    $wednesday_list = []
    $thursday_list = []
    $friday_list = []
    sunday_list = []
    monday_list = []
    tuesday_list = []
    wednesday_list = []
    thursday_list = []
    friday_list = []
    call_lists.each do |c|
      if current_user.email == 'admin' || c.rep == current_user.email.upcase
        case c.callday
        when "SUNDAY"
          sunday_list.push(c)
        when "MONDAY"
          monday_list.push(c)
        when "TUESDAY"
          tuesday_list.push(c)
        when "WEDNESDAY"
          wednesday_list.push(c)
        when "THURSDAY"
          thursday_list.push(c)
        else
          friday_list.push(c)
        end
      end
    end
    $sunday_list = sunday_list.sort_by{ |t| t.custcode }
    $monday_list = monday_list.sort_by{ |t| t.custcode }
    $tuesday_list = tuesday_list.sort_by{ |t| t.custcode }
    $wednesday_list = wednesday_list.sort_by{ |t| t.custcode }
    $thursday_list = thursday_list.sort_by{ |t| t.custcode }
    $friday_list = friday_list.sort_by{ |t| t.custcode }
    @list_length = $sunday_list.length
    if $monday_list.length > @list_length
      @list_length = $monday_list.length
    end
    if $tuesday_list.length > @list_length
      @list_length = $tuesday_list.length
    end
    if $wednesday_list.length > @list_length
      @list_length = $wednesday_list.length
    end
    if $thursday_list.length > @list_length
      @list_length = $thursday_list.length
    end
    if $friday_list.length > @list_length
      @list_length = $friday_list.length
    end
  end

  def multi
    session[:called_isr] = params[:called_isr]
    sunday_list = params[:sunday_isr_call_list]
    update_call_list(sunday_list, $sunday_list)
    monday_list = params[:monday_isr_call_list]
    update_call_list(monday_list, $monday_list)
    tuesday_list = params[:tuesday_isr_call_list]
    update_call_list(tuesday_list, $tuesday_list)
    wednesday_list = params[:wednesday_isr_call_list]
    update_call_list(wednesday_list, $wednesday_list)
    thursday_list = params[:thursday_isr_call_list]
    update_call_list(thursday_list, $thursday_list)
    friday_list = params[:friday_isr_call_list]
    update_call_list(friday_list, $friday_list)
    redirect_to action: "index"
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_call_list
      @call_list = CallList.find(params[:id])
    end

    # Add sales data to parameters
    def load_rep
      @cp = call_list_params
      if !@cp[:rep]
        @cp[:rep] = current_user.email.upcase
      end
    end

    # Use callbacks to share common setup or constraints between actions.
    def build_lists
      @callday = ['SUNDAY', 'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY']
      @callback = [' ', 'SUNDAY', 'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY']
      @contact_method = ['CALL', 'EMAIL', 'TEXT']
      @called = ['NO', 'NO ANSWER', 'YES']
      @ordered = [' ', 'NO', 'YES']
      @windows = ['10am - noon', 'noon - 2pm', '2pm - 4pm', '4pm - 6pm']
    end

    # Build a call list based on selected day and call window
    def build_call_list

      call_lists = CallList.all
      @user = current_user.email
      @call_lists = []
      if current_user.email == 'admin'
        @call_lists = call_lists
      else
        call_lists.each do |c|
          if c.rep == current_user.email.upcase || c.isr == current_user.email.upcase
            @call_lists.push(c)
          end
        end
      end

      call_lists = @call_lists
      if !session[:called_day] || session[:called_day == '']
        # first time in
        session[:called_day] = 'SUNDAY'
        session[:called_window] = 'ALL'
      end

      day = ['SUNDAY', 'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY']
      @day = []
      i = 1
      @selected_day = 0
      day.each do |d|
        select_item = []
        select_item.push(d)
        select_item.push(i)
        @day.push(select_item)
        if d == session[:called_day]
          @selected_day = i
        end
        i += 1
      end
      session[:calllist_days] = @day

      window = ['ALL', '10am - noon', 'noon - 2pm', '2pm - 4pm', '4pm - 6pm']
      @window = []
      i = 1
      @selected_window = 0
      window.each do |d|
        select_item = []
        select_item.push(d)
        select_item.push(i)
        @window.push(select_item)
        if d == session[:called_window]
          @selected_window = i
        end
        i += 1
      end
      session[:calllist_windows] = @window

      @call_lists = []
      # @altcsr = []
      # @usualcsr = []
      # @altcsrs_day = []
      # @custcode = []
      # now = Date.today
      # altcsr = Altcsr.all
      # altcsr.each do |a|
      #   if a.altcsrs_start <= now + 1 && a.altcsrs_end >= now
      #     @altcsr.push(a.altcsr)
      #     @usualcsr.push(a.usualcsr)
      #     @shipto.push(a.shipto)
      #     @altcsrs_day.push(a.altcsrs_day)
      #     @custcode.push(a.custcode)
      #   end
      # end

      call_lists.each do |c|
        if c.rep
          # altcsr_found = false
          # altcsr_length = @altcsr.length
          # i = 0
          # while i < altcsr_length
          #   if @usualcsr[i] == c.csr && session[:called_csr] == @altcsr[i] && c.custcode == @custcode[i] && c.shipto == @shipto[i] && c.calllists_day == @altcsrs_day[i]
          #     altcsr_found = true
          #     break
          #   end
          #   i += 1
          # end
          if !c.window || c.window == ''
            c.window = 'ALL'
          end
          # if (c.callday == session[:called_day] || c.callback == session[:called_day]) && (c.window == session[:called_window] || altcsr_found)
          if (c.callday == session[:called_day] || c.callback == session[:called_day]) && (c.window == session[:called_window] || session[:called_window] == "ALL")
            # include call list records that are a direct match for csr and also if there is an altcsr override active for another csr
            @call_lists.push(c)
          end
        end
      end
    end

    # After seven days reset the called flag to false.
    def reset_called_flag
      now = Date.today
      a_week_ago = now - 6
      call_lists = CallList.all
      call_lists.each do |c|
        if c.called && c.called != 'NO' && (!c.date_called || c.date_called < a_week_ago)
          c.called = 'NO'
          c.ordered = ' '
          c.save
        end
        if c.callback && c.callback != '' && (!c.callback_date || c.callback_date < a_week_ago)
          c.callback = ''
          c.save
        end
      end
    end

    def update_call_list(isr_list, call_list)
      if isr_list
        isr_call_list = []
        i = 0
        while i < isr_list.length
          if isr_list[i] == '0' && isr_list[i+1] == '1'
            isr_call_list.push('1')
            i += 1
          else
            isr_call_list.push('0')
          end
          i += 1
        end
        i = 0
        while i < call_list.length
          if isr_call_list[i] == '1'
            call_list[i].isr = params[:called_isr]
          else
            call_list[i].isr = ''
          end
          call_list[i].save
          i += 1
        end
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def call_list_params
      params.require(:call_list).permit(:custcode, :custname, :contact_method, :callday, :notes, :contact, :phone, :email, :selling, :main_phone, :website, :rep, :isr, :called, :date_called, :ordered, :date_ordered, :callback, :callback_date, :window, :sunday_isr_call_list[], :monday_isr_call_list[], :tuesday_isr_call_list[], :wednesday_isr_call_list[], :thursday_isr_call_list[], :friday_isr_call_list[])
    end
end
