class CallListsController < ApplicationController
  before_action :set_call_list, only: [:show, :edit, :update, :destroy]
  before_action :set_user_and_manager
  before_action :build_lists, only: [:new, :edit, :list, :index]
  before_action :build_call_list, only: [:index]
  before_action :reset_called_flag, only: [:index, :list]
  before_action :get_call_list, only: [:not_called, :not_ordered, :not_on_list, :no_customer]

  # GET /call_lists
  def index
    $title = 'Call Lists'
  end

  # GET /call_lists/1
  def show
    $title = 'Show Call List'
  end

  # GET /call_lists/new
  def new
    $title = 'Add Call List'
    @new = true
    @call_list = CallList.new
    if !@isr_user
      @call_list.call_days.build
    end
  end

  # GET /call_lists/1/edit
  def edit
    $title = 'Edit Call List'
    @new = false
    if !@isr_user
      @call_list.call_days.build
    end
  end

  # POST /call_lists
  def create
    $title = 'Add Call List'
    cp = call_list_params
    cp[:rep] = current_user.email.upcase
    @call_list = CallList.new(cp)

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
    $title = 'Edit Call List'
    cp = call_list_params
    i = 0
    @call_list.call_days.each do |c|
      if call_list_params[:call_days_attributes][i.to_s][:callback] && c.callback != call_list_params[:call_days_attributes][i.to_s][:callback] && call_list_params[:call_days_attributes][i.to_s][:callback] != ' '
        cp[:call_days_attributes][i.to_s][:callback_date] = Date.today
        cp[:call_days_attributes][i.to_s][:called] = 'NO'
      end
      if call_list_params[:call_days_attributes][i.to_s][:called] && c.called != call_list_params[:call_days_attributes][i.to_s][:called] && call_list_params[:call_days_attributes][i.to_s][:called] == 'YES'
        cp[:call_days_attributes][i.to_s][:date_called] = Date.today
      end
      if call_list_params[:call_days_attributes][i.to_s][:ordered] && c.ordered != call_list_params[:call_days_attributes][i.to_s][:ordered] && call_list_params[:call_days_attributes][i.to_s][:ordered] == 'YES'
        cp[:call_days_attributes][i.to_s][:date_ordered] = Date.today
      end
      i += 1
    end
    respond_to do |format|
      if @call_list.update(cp)
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
    reps = []
    reps = session[:calllist_reps]
    reps.each do |r|
      select_item = []
      select_item = r
      if params[:called_rep] == select_item[1].to_s
        session[:called_rep] = select_item[0]
        break
      end
    end
    redirect_to action: "index"
  end

  def week_select
    reps = []
    reps = session[:calllist_reps]
    reps.each do |r|
      select_item = []
      select_item = r
      if params[:called_rep] == select_item[1].to_s
        session[:called_rep] = select_item[0]
        break
      end
    end
    redirect_to action: "list"
  end

  def import
    CallList.import(params[:file])
    # need to create an override record for each call list record
    calllist = CallList.all
    now = Date.today
    yesterday = now - 1
    calllist.each do |c|
      override = OverrideCallList.new
      override.custcode = c.custcode
      override.custname = c.custname
      override.contact_method = c.contact_method
      override.contact = c.contact
      override.phone = c.phone
      override.email = c.email
      override.selling = c.selling
      override.main_phone = c.main_phone
      override.website = c.website
      override.rep = c.rep
      override.override_start = yesterday
      override.override_end = yesterday
      override.save
    end
    redirect_to root_url, notice: "Call list imported."
  end

  def not_called
    $title = 'Not Contacted This Week'
  end

  def not_ordered
    $title = 'Not Ordered This Week'
  end

  def not_on_list
    $title = 'Active Customers Not On Call List'
    call_list = @report_list.sort_by{ |t| t.custcode }
    list = ActiveCustomer.where(rep: @user).to_a
    active_customer = list.sort_by{ |t| t.custcode }
    @missing_call_list = []
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
    $title = 'Call Lists With No Active Customer'
    call_list = @report_list.sort_by{ |t| t.custcode }
    list = ActiveCustomer.where(rep: @user).to_a
    active_customer = list.sort_by{ |t| t.custcode }
    @missing_customer = []
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
    $title = 'All Active Customers'
    customer_list = []
    user = User.find_by(email: current_user.email)
    if @user == user.manager_id.upcase
      # this is a manager so get all the ActiveCustomer data for the reps that report to them also
      users = User.where(manager_id: @user)
      users.each do |u|
        list = ActiveCustomer.where(rep: u.email.upcase).to_a
        list.each {|i| customer_list << i }
      end
    else
      customer_list = ActiveCustomer.where(rep: @user).to_a
    end
    report_list = customer_list.sort_by{ |t| t.custcode }
    customer = report_list[report_list.length - 1]
    @report_list = []
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

  def isrlist
    @isr = params[:isr]
    $title = "This Week's Call List For " + @isr
    $isr = params[:isr]
    call_days = CallDay.where(isr: @isr)
    @sunday_isrlist1 = []
    @sunday_isrlist2 = []
    @sunday_isrlist3 = []
    @sunday_isrlist4 = []
    @monday_isrlist1 = []
    @monday_isrlist2 = []
    @monday_isrlist3 = []
    @monday_isrlist4 = []
    @tuesday_isrlist1 = []
    @tuesday_isrlist2 = []
    @tuesday_isrlist3 = []
    @tuesday_isrlist4 = []
    @wednesday_isrlist1 = []
    @wednesday_isrlist2 = []
    @wednesday_isrlist3 = []
    @wednesday_isrlist4 = []
    @thursday_isrlist1 = []
    @thursday_isrlist2 = []
    @thursday_isrlist3 = []
    @thursday_isrlist4 = []
    @friday_isrlist1 = []
    @friday_isrlist2 = []
    @friday_isrlist3 = []
    @friday_isrlist4 = []
    call_days.each do |c|
      call_list = CallList.find(c.call_list_id)
      if !c.callback || c.callback == ' '
        # no callback
        case c.callday
        when 'MONDAY'
          case c.window
          when '10am - noon'
            @monday_isrlist1.push(call_list)
          when 'noon - 2pm'
            @monday_isrlist2.push(call_list)
          when '2pm - 4pm'
            @monday_isrlist3.push(call_list)
          else
            @monday_isrlist4.push(call_list)
          end
        when 'TUESDAY'
          case c.window
          when '10am - noon'
            @tuesday_isrlist1.push(call_list)
          when 'noon - 2pm'
            @tuesday_isrlist2.push(call_list)
          when '2pm - 4pm'
            @tuesday_isrlist3.push(call_list)
          else
            @tuesday_isrlist4.push(call_list)
          end
        when 'WEDNESDAY'
          case c.window
          when '10am - noon'
            @wednesday_isrlist1.push(call_list)
          when 'noon - 2pm'
            @wednesday_isrlist2.push(call_list)
          when '2pm - 4pm'
            @wednesday_isrlist3.push(call_list)
          else
            @wednesday_isrlist4.push(call_list)
          end
        when 'THURSDAY'
          case c.window
          when '10am - noon'
            @thursday_isrlist1.push(call_list)
          when 'noon - 2pm'
            @thursday_isrlist2.push(call_list)
          when '2pm - 4pm'
            @thursday_isrlist3.push(call_list)
          else
            @thursday_isrlist4.push(call_list)
          end
        when 'FRIDAY'
          case c.window
          when '10am - noon'
            @friday_isrlist1.push(call_list)
          when 'noon - 2pm'
            @friday_isrlist2.push(call_list)
          when '2pm - 4pm'
            @friday_isrlist3.push(call_list)
          else
            @friday_isrlist4.push(call_list)
          end
        end
      else
        # callback in force
        case c.callback
        when 'MONDAY'
          case c.window
          when '10am - noon'
            @monday_isrlist1.push(call_list)
          when 'noon - 2pm'
            @monday_isrlist2.push(call_list)
          when '2pm - 4pm'
            @monday_isrlist3.push(call_list)
          else
            @monday_isrlist4.push(call_list)
          end
        when 'TUESDAY'
          case c.window
          when '10am - noon'
            @tuesday_isrlist1.push(call_list)
          when 'noon - 2pm'
            @tuesday_isrlist2.push(call_list)
          when '2pm - 4pm'
            @tuesday_isrlist3.push(call_list)
          else
            @tuesday_isrlist4.push(call_list)
          end
        when 'WEDNESDAY'
          case c.window
          when '10am - noon'
            @wednesday_isrlist1.push(call_list)
          when 'noon - 2pm'
            @wednesday_isrlist2.push(call_list)
          when '2pm - 4pm'
            @wednesday_isrlist3.push(call_list)
          else
            @wednesday_isrlist4.push(call_list)
          end
        when 'THURSDAY'
          case c.window
          when '10am - noon'
            @thursday_isrlist1.push(call_list)
          when 'noon - 2pm'
            @thursday_isrlist2.push(call_list)
          when '2pm - 4pm'
            @thursday_isrlist3.push(call_list)
          else
            @thursday_isrlist4.push(call_list)
          end
        when 'FRIDAY'
          case c.window
          when '10am - noon'
            @friday_isrlist1.push(call_list)
          when 'noon - 2pm'
            @friday_isrlist2.push(call_list)
          when '2pm - 4pm'
            @friday_isrlist3.push(call_list)
          else
            @friday_isrlist4.push(call_list)
          end
        end
      end
    end
    @list_length = @sunday_isrlist1.length
    if @sunday_isrlist2.length > @list_length
      @list_length = @sunday_isrlist2.length
    end
    if @sunday_isrlist3.length > @list_length
      @list_length = @sunday_isrlist3.length
    end
    if @sunday_isrlist4.length > @list_length
      @list_length = @sunday_isrlist4.length
    end
    if @monday_isrlist1.length > @list_length
      @list_length = @monday_isrlist1.length
    end
    if @monday_isrlist2.length > @list_length
      @list_length = @monday_isrlist2.length
    end
    if @monday_isrlist3.length > @list_length
      @list_length = @monday_isrlist3.length
    end
    if @monday_isrlist4.length > @list_length
      @list_length = @monday_isrlist4.length
    end
    if @tuesday_isrlist1.length > @list_length
      @list_length = @tuesday_isrlist1.length
    end
    if @tuesday_isrlist2.length > @list_length
      @list_length = @tuesday_isrlist2.length
    end
    if @tuesday_isrlist3.length > @list_length
      @list_length = @tuesday_isrlist3.length
    end
    if @tuesday_isrlist4.length > @list_length
      @list_length = @tuesday_isrlist4.length
    end
    if @wednesday_isrlist1.length > @list_length
      @list_length = @wednesday_isrlist1.length
    end
    if @wednesday_isrlist2.length > @list_length
      @list_length = @wednesday_isrlist2.length
    end
    if @wednesday_isrlist3.length > @list_length
      @list_length = @wednesday_isrlist3.length
    end
    if @wednesday_isrlist4.length > @list_length
      @list_length = @wednesday_isrlist4.length
    end
    if @thursday_isrlist1.length > @list_length
      @list_length = @thursday_isrlist1.length
    end
    if @thursday_isrlist2.length > @list_length
      @list_length = @thursday_isrlist2.length
    end
    if @thursday_isrlist3.length > @list_length
      @list_length = @thursday_isrlist3.length
    end
    if @thursday_isrlist4.length > @list_length
      @list_length = @thursday_isrlist4.length
    end
    if @friday_isrlist1.length > @list_length
      @list_length = @friday_isrlist1.length
    end
    if @friday_isrlist2.length > @list_length
      @list_length = @friday_isrlist2.length
    end
    if @friday_isrlist3.length > @list_length
      @list_length = @friday_isrlist3.length
    end
    if @friday_isrlist4.length > @list_length
      @list_length = @friday_isrlist4.length
    end
  end

  def isr_week
    $title = "ISR Week"
    @weekhash = []
    tempday = CallDay.all
    tempday.each do |t|
      if !t.isr
        t.isr = ' '
      end
    end
    call_days = tempday.sort_by { |t| [t.isr] }
    sun_1 = 0
    sun_2 = 0
    sun_3 = 0
    sun_4 = 0
    mon_1 = 0
    mon_2 = 0
    mon_3 = 0
    mon_4 = 0
    tue_1 = 0
    tue_2 = 0
    tue_3 = 0
    tue_4 = 0
    wed_1 = 0
    wed_2 = 0
    wed_3 = 0
    wed_4 = 0
    thu_1 = 0
    thu_2 = 0
    thu_3 = 0
    thu_4 = 0
    fri_1 = 0
    fri_2 = 0
    fri_3 = 0
    fri_4 = 0
    tot = 0
    first_call_day = call_days.first
    isr = first_call_day.isr
    i = 0
    call_days.each do |c|
      if c.isr && c.isr.length > 0
        if isr && c.isr != isr && isr.length > 0
          if isr != ' '
            @weekhash.push({isr: isr, sun_1: sun_1, sun_2: sun_2, sun_3: sun_3, sun_4: sun_4, mon_1: mon_1, mon_2: mon_2, mon_3: mon_3, mon_4: mon_4, tue_1: tue_1, tue_2: tue_2, tue_3: tue_3, tue_4: tue_4, wed_1: wed_1, wed_2: wed_2, wed_3: wed_3, wed_4: wed_4, thu_1: thu_1, thu_2: thu_2, thu_3: thu_3, thu_4: thu_4, fri_1: fri_1, fri_2: fri_2, fri_3: fri_3, fri_4: fri_4, tot: tot})
          end
          sun_1 = 0
          sun_2 = 0
          sun_3 = 0
          sun_4 = 0
          mon_1 = 0
          mon_2 = 0
          mon_3 = 0
          mon_4 = 0
          tue_1 = 0
          tue_2 = 0
          tue_3 = 0
          tue_4 = 0
          wed_1 = 0
          wed_2 = 0
          wed_3 = 0
          wed_4 = 0
          thu_1 = 0
          thu_2 = 0
          thu_3 = 0
          thu_4 = 0
          fri_1 = 0
          fri_2 = 0
          fri_3 = 0
          fri_4 = 0
          tot = 0
        end
        isr = c.isr
        tot += 1
        if !c.callback || c.callback == ' '
          # no callback
          case c.callday
          when 'SUNDAY'
            case c.window
            when '10am - noon'
              sun_1 += 1
            when 'noon - 2pm'
              sun_2 += 1
            when '2pm - 4pm'
              sun_3 += 1
            else
              sun_4 += 1
            end
          when 'MONDAY'
            case c.window
            when '10am - noon'
              mon_1 += 1
            when 'noon - 2pm'
              mon_2 += 1
            when '2pm - 4pm'
              mon_3 += 1
            else
              mon_4 += 1
            end
          when 'TUESDAY'
            case c.window
            when '10am - noon'
              tue_1 += 1
            when 'noon - 2pm'
              tue_2 += 1
            when '2pm - 4pm'
              tue_3 += 1
            else
              tue_4 += 1
            end
          when 'WEDNESDAY'
            case c.window
            when '10am - noon'
              wed_1 += 1
            when 'noon - 2pm'
              wed_2 += 1
            when '2pm - 4pm'
              wed_3 += 1
            else
              wed_4 += 1
            end
          when 'THURSDAY'
            case c.window
            when '10am - noon'
              thu_1 += 1
            when 'noon - 2pm'
              thu_2 += 1
            when '2pm - 4pm'
              thu_3 += 1
            else
              thu_4 += 1
            end
          else
            case c.window
            when '10am - noon'
              fri_1 += 1
            when 'noon - 2pm'
              fri_2 += 1
            when '2pm - 4pm'
              fri_3 += 1
            else
              fri_4 += 1
            end
          end
        else
          #callback in force
          case c.callback
          when 'SUNDAY'
            case c.window
            when '10am - noon'
              sun_1 += 1
            when 'noon - 2pm'
              sun_2 += 1
            when '2pm - 4pm'
              sun_3 += 1
            else
              sun_4 += 1
            end
          when 'MONDAY'
            case c.window
            when '10am - noon'
              mon_1 += 1
            when 'noon - 2pm'
              mon_2 += 1
            when '2pm - 4pm'
              mon_3 += 1
            else
              mon_4 += 1
            end
          when 'TUESDAY'
            case c.window
            when '10am - noon'
              tue_1 += 1
            when 'noon - 2pm'
              tue_2 += 1
            when '2pm - 4pm'
              tue_3 += 1
            else
              tue_4 += 1
            end
          when 'WEDNESDAY'
            case c.window
            when '10am - noon'
              wed_1 += 1
            when 'noon - 2pm'
              wed_2 += 1
            when '2pm - 4pm'
              wed_3 += 1
            else
              wed_4 += 1
            end
          when 'THURSDAY'
            case c.window
            when '10am - noon'
              thu_1 += 1
            when 'noon - 2pm'
              thu_2 += 1
            when '2pm - 4pm'
              thu_3 += 1
            else
              thu_4 += 1
            end
          else
            case c.window
            when '10am - noon'
              fri_1 += 1
            when 'noon - 2pm'
              fri_2 += 1
            when '2pm - 4pm'
              fri_3 += 1
            else
              fri_4 += 1
            end
          end
        end
      end
    end
    if isr != ' '
      @weekhash.push({isr: isr, sun_1: sun_1, sun_2: sun_2, sun_3: sun_3, sun_4: sun_4, mon_1: mon_1, mon_2: mon_2, mon_3: mon_3, mon_4: mon_4, tue_1: tue_1, tue_2: tue_2, tue_3: tue_3, tue_4: tue_4, wed_1: wed_1, wed_2: wed_2, wed_3: wed_3, wed_4: wed_4, thu_1: thu_1, thu_2: thu_2, thu_3: thu_3, thu_4: thu_4, fri_1: fri_1, fri_2: fri_2, fri_3: fri_3, fri_4: fri_4, tot: tot})
    end
  end

  def replist
    call_lists = CallList.all
    @sunday_replist1 = []
    @sunday_replist2 = []
    @sunday_replist3 = []
    @sunday_replist4 = []
    @monday_replist1 = []
    @monday_replist2 = []
    @monday_replist3 = []
    @monday_replist4 = []
    @tuesday_replist1 = []
    @tuesday_replist2 = []
    @tuesday_replist3 = []
    @tuesday_replist4 = []
    @wednesday_replist1 = []
    @wednesday_replist2 = []
    @wednesday_replist3 = []
    @wednesday_replist4 = []
    @thursday_replist1 = []
    @thursday_replist2 = []
    @thursday_replist3 = []
    @thursday_replist4 = []
    @friday_replist1 = []
    @friday_replist2 = []
    @friday_replist3 = []
    @friday_replist4 = []
    @rep = params[:rep]
    $rep = params[:rep]
    $title = "This Week's Call List For " + @rep
    call_lists.each do |c|
      override = OverrideCallList.find_by(custcode: c.custcode)
      today = Date.today
      if override.override_end >= today && override.override_start <= today
        # check if the override for this customer is active
        c.custcode = override.custcode
        c.custname = override.custname
        c.contact_method = override.contact_method
        c.contact = override.contact
        c.phone = override.phone
        c.email = override.email
        c.selling = override.selling
        c.main_phone = override.main_phone
        c.website = override.website
        c.rep = override.rep
      end
    end
  end

  def rep_week
    $title = "Rep Week"
    @weekhash = []
    templist = CallList.all
    call_lists = templist.sort_by{|t| [t.rep]}
    sun_1 = 0
    sun_2 = 0
    sun_3 = 0
    sun_4 = 0
    mon_1 = 0
    mon_2 = 0
    mon_3 = 0
    mon_4 = 0
    tue_1 = 0
    tue_2 = 0
    tue_3 = 0
    tue_4 = 0
    wed_1 = 0
    wed_2 = 0
    wed_3 = 0
    wed_4 = 0
    thu_1 = 0
    thu_2 = 0
    thu_3 = 0
    thu_4 = 0
    fri_1 = 0
    fri_2 = 0
    fri_3 = 0
    fri_4 = 0
    tot = 0
    first_call_list = call_lists.first
    rep = first_call_list.rep
    i = 0
    call_lists.each do |c|
      override = OverrideCallList.find_by(custcode: c.custcode)
      today = Date.today
      if override.override_end >= today && override.override_start <= today
        # check if the override for this customer is active
        # c.callday = override.callday
        c.rep = override.rep
      end
    end
  end

  def custname
    call_day = CallDay.find(params[:callday_id])
    session[:called_day] = call_day.callday
    session[:called_window] = call_day.window
    redirect_to action: "index"
  end

  def list
    $title = "This Week's Call List"
    rep_array = []
    if @manager
      if session[:called_rep] == 'ALL'
        # load all reps in @reps
        @reps.each do |r|
          if r[0] != 'ALL'
            rep_array.push(r[0])
          end
        end
      else
        rep_array.push(session[:called_rep])
      end
    else
      rep_array.push(@user)
    end
    call_lists = CallList.all
    if session[:called_isr].blank?
      session[:called_isr] = ' '
    end
    $call_lists = []
    call_lists.each do |c|
      override = OverrideCallList.find_by(custcode: c.custcode)
      today = Date.today
      if override && override.override_end >= today && override.override_start <= today
        # check if the override for this customer is active
        c.rep = override.rep
      end
      if rep_array.include?(c.rep)
        sun_id = nil
        sun_isr = nil
        mon_id = nil
        mon_isr = nil
        tue_id = nil
        tue_isr = nil
        wed_id = nil
        wed_isr = nil
        thu_id = nil
        thu_isr = nil
        fri_id = nil
        fri_isr = nil
        c.call_days.each do |d|
          if d.callback.blank?
            # no callback
            case d.callday
            when "SUNDAY"
              sun_id = d.id
              sun_isr = d.isr
              if sun_isr.blank?
                sun_isr = ' '
              end
            when "MONDAY"
              mon_id = d.id
              mon_isr = d.isr
              if mon_isr.blank?
                mon_isr = ' '
              end
            when "TUESDAY"
              tue_id = d.id
              tue_isr = d.isr
              if tue_isr.blank?
                tue_isr = ' '
              end
            when "WEDNESDAY"
              wed_id = d.id
              wed_isr = d.isr
              if wed_isr.blank?
                wed_isr = ' '
              end
            when "THURSDAY"
              thu_id = d.id
              thu_isr = d.isr
              if thu_isr.blank?
                thu_isr = ' '
              end
            else
              fri_id = d.id
              fri_isr = d.isr
              if fri_isr.blank?
                fri_isr = ' '
              end
            end
          else
            # callback in force
            case d.callback
            when "SUNDAY"
              sun_id = d.id
              sun_isr = d.isr
              if sun_isr.blank?
                sun_isr = ' '
              end
            when "MONDAY"
              mon_id = d.id
              mon_isr = d.isr
              if mon_isr.blank?
                mon_isr = ' '
              end
            when "TUESDAY"
              tue_id = d.id
              tue_isr = d.isr
              if tue_isr.blank?
                tue_isr = ' '
              end
            when "WEDNESDAY"
              wed_id = d.id
              wed_isr = d.isr
              if wed_isr.blank?
                wed_isr = ' '
              end
            when "THURSDAY"
              thu_id = d.id
              thu_isr = d.isr
              if thu_isr.blank?
                thu_isr = ' '
              end
            else
              fri_id = d.id
              fri_isr = d.isr
              if fri_isr.blank?
                fri_isr = ' '
              end
            end # case
          end # if callback
        end # call_days do
        $call_lists.push({calllist_id: c.id, customer: c.custname, sun_id: sun_id, sun_isr: sun_isr, mon_id: mon_id, mon_isr: mon_isr, tue_id: tue_id, tue_isr: tue_isr, wed_id: wed_id, wed_isr: wed_isr, thu_id: thu_id, thu_isr: thu_isr, fri_id: fri_id, fri_isr: fri_isr})
      end # if admin
    end # call_lists do
  end

  def multi
    sunday_list = params[:sunday_isr_call_list]
    monday_list = params[:monday_isr_call_list]
    tuesday_list = params[:tuesday_isr_call_list]
    wednesday_list = params[:wednesday_isr_call_list]
    thursday_list = params[:thursday_isr_call_list]
    friday_list = params[:friday_isr_call_list]
    sun_i = 0
    mon_i = 0
    tue_i = 0
    wed_i = 0
    thu_i = 0
    fri_i = 0
    $call_lists.each do |c|
      if c[:sun_id]
        d = CallDay.find(c[:sun_id])
        d.isr = sunday_list[sun_i]
        sun_i += 1
        d.save
      end
      if c[:mon_id]
        d = CallDay.find(c[:mon_id])
        d.isr = monday_list[mon_i]
        mon_i += 1
        d.save
      end
      if c[:tue_id]
        d = CallDay.find(c[:tue_id])
        d.isr = tuesday_list[tue_i]
        tue_i += 1
        d.save
      end
      if c[:wed_id]
        d = CallDay.find(c[:wed_id])
        d.isr = wednesday_list[wed_i]
        wed_i += 1
        d.save
      end
      if c[:thu_id]
        d = CallDay.find(c[:thu_id])
        d.isr = thursday_list[thu_i]
        thu_i += 1
        d.save
    end
      if c[:fri_id]
        d = CallDay.find(c[:fri_id])
        d.isr = friday_list[fri_i]
        fri_i += 1
        d.save
      end
    end
    redirect_to action: "index"
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_call_list
      @call_list = CallList.find(params[:id])
    end

    def set_user_and_manager
      @user = current_user.email.upcase
      @manager = false
      if @user == 'ADMIN' || current_user.manager_id.upcase == @user
        @manager = true
      end
    end

    # Use callbacks to share common setup or constraints between actions.
    def build_lists
      @callday = [' ','SUNDAY', 'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY']
      @callback = [' ', 'SUNDAY', 'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY']
      @contact_method = ['CALL', 'EMAIL', 'TEXT']
      @called = ['NO', 'NO ANSWER', 'YES']
      @ordered = [' ', 'NO', 'YES']
      @windows = ['10am - noon', 'noon - 2pm', '2pm - 4pm', '4pm - 6pm']
      @alt_contact = [' ', 'ZINGLE', 'TEXT', 'VOICE MAIL', 'OTHER']
      @rep = []
      reps = []

      if @user == 'ADMIN'
        users = User.all
      else
        users = User.where(manager_id: current_user.manager_id.upcase)
      end
      users.each do |u|
        if u.email.upcase != 'ADMIN' && u.email.upcase != 'TECH'
          reps.push(u.email.upcase)
        end
      end
      reps.sort!
      reps.each do |r|
        @rep.push(r)
      end
      reps.unshift("ALL")
      if session[:called_rep].blank?
        if @user == 'ADMIN' || @user == 'TECH'
          session[:called_rep] = reps[1]
        else
          session[:called_rep] = @user
        end
      end
      @reps = []
      i = 1
      @selected_rep = 0
      reps.each do |r|
        select_item = []
        select_item.push(r)
        select_item.push(i)
        @reps.push(select_item)
        if r == session[:called_rep]
          @selected_rep = i
        end
        i += 1
      end
      session[:calllist_reps] = @reps

      @isr_list = []
      tempisr = []
      tempisr.push(' ')
      isrlist = IsrList.all
      isrlist.each do |c|
        if c.name && !tempisr.include?(c.name)
          tempisr.push(c.name)
        end
      end
      @isr_list = tempisr.sort
      @isr_user = false
      if @isr_list.include?(@user)
        @isr_user = true
      end
    end

    # Build a call list based on selected day and call window
    def build_call_list
      if session[:called_day].blank?
        # if !session[:called_day] || session[:called_day == '']
        session[:called_day] = 'SUNDAY'
        session[:called_window] = 'ALL'
      end
      rep_array = []
      if @manager
        if session[:called_rep] == 'ALL'
          # load all reps in @reps
          @reps.each do |r|
            if r[0] != 'ALL'
              rep_array.push(r[0])
            end
          end
        else
          rep_array.push(session[:called_rep])
        end
      else
        rep_array.push(@user)
      end
      @call_lists = []
      cls = CallList.all
      cls.each do |c|
        override = OverrideCallList.find_by(custcode: c.custcode)
        today = Date.today
        if override && override.override_end >= today && override.override_start <= today
          # check if the override for this customer is active
          c.custcode = override.custcode
          c.custname = override.custname
          c.contact_method = override.contact_method
          c.contact = override.contact
          c.phone = override.phone
          c.email = override.email
          c.selling = override.selling
          c.main_phone = override.main_phone
          c.website = override.website
          c.rep = override.rep
        end
        c.call_days.each do |d|
          # see if there are call day records for the current selections and user
          if ((d.callday == session[:called_day] && d.callback.blank?) || d.callback == session[:called_day]) && (d.window == session[:called_window] || session[:called_window] == 'ALL') && (rep_array.include?(c.rep) || rep_array.include?(d.isr))
            @call_lists.push(c)
            break
          end
        end
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
      tempisr = []
      isrlist = IsrList.all
      isrlist.each do |c|
        if c.name && !tempisr.include?(c.name)
          tempisr.push(c.name)
        end
      end
      @isr_list = tempisr.sort
      @isr_user = false
      if @isr_list.include?(@user)
        @isr_user = true
      end
    end

    # After seven days reset the called flag to false.
    def reset_called_flag
      now = Date.today
      a_week_ago = now - 6
      call_days = CallDay.all
      call_days.each do |c|
        if ((c.called && c.called == 'YES') || (c.ordered && c.ordered == 'YES')) && ((c.date_called && c.date_called < a_week_ago) || (c.date_called && c.date_called < a_week_ago))
          c.called = 'NO'
          c.ordered = ' '
          c.callback = ' '
          c.alt_contact = ' '
          c.save
        end
      end
    end

    def get_call_list
      user = User.find_by(email: current_user.email)
      if @user == user.manager_id.upcase
        # this is a manager so get all the call_list data for the reps that report to them also
        @report_list = []
        users = User.where(manager_id: @user)
        users.each do |u|
          list = CallList.where(rep: u.email.upcase).to_a
          list.each {|i| @report_list << i }
        end
      else
        @report_list = CallList.where(rep: @user).to_a
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def call_list_params
      params.require(:call_list).permit(:custcode, :custname, :contact_method, :contact, :phone, :email, :selling, :main_phone, :website, :rep, :sunday_isr_call_list, :monday_isr_call_list, :tuesday_isr_call_list, :wednesday_isr_call_list, :thursday_isr_call_list, :friday_isr_call_list, :sunday_rep_call_list, :monday_rep_call_list, :tuesday_rep_call_list, :wednesday_rep_call_list, :thursday_rep_call_list, :friday_rep_call_list,
        call_days_attributes: [
          :id,
          :callday,
          :notes,
          :isr,
          :called,
          :date_called,
          :ordered,
          :date_ordered,
          :callback,
          :callback_date,
          :window,
          :alt_contact
        ]
      )
    end
end
