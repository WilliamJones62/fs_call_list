class CallListsController < ApplicationController
  before_action :set_call_list, only: [:show, :edit, :update, :destroy]
  before_action :build_lists, only: [:new, :edit, :list]
  before_action :build_call_list, only: [:index]
  before_action :reset_called_flag, only: [:index, :list]

  # GET /call_lists
  def index
  end

  # GET /call_lists/1
  def show
  end

  # GET /call_lists/new
  def new
    @call_list = CallList.new
    if !@isr_user
      @call_list.call_days.build
    end
  end

  # GET /call_lists/1/edit
  def edit
    if !@isr_user
      @call_list.call_days.build
    end
  end

  # POST /call_lists
  def create
    cp = call_list_params
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
    redirect_to action: "index"
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
    @user = current_user.email.upcase
    @report_list = CallList.where(rep: @user).to_a
  end

  def not_ordered
    @user = current_user.email.upcase
    @report_list = CallList.where(rep: @user).to_a
  end

  def not_on_list
    @user = current_user.email.upcase
    list = CallList.where(rep: @user).to_a
    call_list = list.sort_by{ |t| t.custcode }
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
    @user = current_user.email.upcase
    list = CallList.where(rep: @user).to_a
    call_list = list.sort_by{ |t| t.custcode }
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
    @user = current_user.email.upcase
    @report_list = []
    customer_list = ActiveCustomer.where(rep: @user).to_a
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

  def isrlist
    @isr = params[:isr]
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
      if c.callback == ' '
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
    @weekhash = []
    tempday = CallDay.all
    call_days = tempday.sort_by{|t| [t.isr]}
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
        if c.callback == ' '
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
    call_lists.each do |c|
      override = OverrideCallList.find_by(custcode: c.custcode)
      today = Date.today
      if override.override_end >= today && override.override_start <= today
        # check if the override for this customer is active
        c.custcode = override.custcode
        c.custname = override.custname
        c.contact_method = override.contact_method
        # c.callday = override.callday
        # c.notes = override.notes
        c.contact = override.contact
        c.phone = override.phone
        c.email = override.email
        c.selling = override.selling
        c.main_phone = override.main_phone
        c.website = override.website
        c.rep = override.rep
        # c.isr = override.isr
        # c.called = override.called
        # c.date_called = override.date_called
        # c.ordered = override.ordered
        # c.date_ordered = override.date_ordered
        # c.callback = override.callback
        # c.callback_date = override.callback_date
        # c.window = override.window
      end
  #     if c.rep == current_user.email.upcase
  #       case c.callday
  #       when 'SUNDAY'
  #         case c.window
  #         when '10am - noon'
  #           @sunday_replist1.push(c)
  #         when 'noon - 2pm'
  #           @sunday_replist2.push(c)
  #         when '2pm - 4pm'
  #           @sunday_replist3.push(c)
  #         else
  #           @sunday_replist4.push(c)
  #         end
  #       when 'MONDAY'
  #         case c.window
  #         when '10am - noon'
  #           @monday_replist1.push(c)
  #         when 'noon - 2pm'
  #           @monday_replist2.push(c)
  #         when '2pm - 4pm'
  #           @monday_replist3.push(c)
  #         else
  #           @monday_replist4.push(c)
  #         end
  #       when 'TUESDAY'
  #         case c.window
  #         when '10am - noon'
  #           @tuesday_replist1.push(c)
  #         when 'noon - 2pm'
  #           @tuesday_replist2.push(c)
  #         when '2pm - 4pm'
  #           @tuesday_replist3.push(c)
  #         else
  #           @tuesday_replist4.push(c)
  #         end
  #       when 'WEDNESDAY'
  #         case c.window
  #         when '10am - noon'
  #           @wednesday_replist1.push(c)
  #         when 'noon - 2pm'
  #           @wednesday_replist2.push(c)
  #         when '2pm - 4pm'
  #           @wednesday_replist3.push(c)
  #         else
  #           @wednesday_replist4.push(c)
  #         end
  #       when 'THURSDAY'
  #         case c.window
  #         when '10am - noon'
  #           @thursday_replist1.push(c)
  #         when 'noon - 2pm'
  #           @thursday_replist2.push(c)
  #         when '2pm - 4pm'
  #           @thursday_replist3.push(c)
  #         else
  #           @thursday_replist4.push(c)
  #         end
  #       when 'FRIDAY'
  #         case c.window
  #         when '10am - noon'
  #           @friday_replist1.push(c)
  #         when 'noon - 2pm'
  #           @friday_replist2.push(c)
  #         when '2pm - 4pm'
  #           @friday_replist3.push(c)
  #         else
  #           @friday_replist4.push(c)
  #         end
  #       end
  #     end
  #   end
  #   @list_length = @sunday_replist1.length
  #   if @sunday_replist2.length > @list_length
  #     @list_length = @sunday_replist2.length
  #   end
  #   if @sunday_replist3.length > @list_length
  #     @list_length = @sunday_replist3.length
  #   end
  #   if @sunday_replist4.length > @list_length
  #     @list_length = @sunday_replist4.length
  #   end
  #   if @monday_replist1.length > @list_length
  #     @list_length = @monday_replist1.length
  #   end
  #   if @monday_replist2.length > @list_length
  #     @list_length = @monday_replist2.length
  #   end
  #   if @monday_replist3.length > @list_length
  #     @list_length = @monday_replist3.length
  #   end
  #   if @monday_replist4.length > @list_length
  #     @list_length = @monday_replist4.length
  #   end
  #   if @tuesday_replist1.length > @list_length
  #     @list_length = @tuesday_replist1.length
  #   end
  #   if @tuesday_replist2.length > @list_length
  #     @list_length = @tuesday_replist2.length
  #   end
  #   if @tuesday_replist3.length > @list_length
  #     @list_length = @tuesday_replist3.length
  #   end
  #   if @tuesday_replist4.length > @list_length
  #     @list_length = @tuesday_replist4.length
  #   end
  #   if @wednesday_replist1.length > @list_length
  #     @list_length = @wednesday_replist1.length
  #   end
  #   if @wednesday_replist2.length > @list_length
  #     @list_length = @wednesday_replist2.length
  #   end
  #   if @wednesday_replist3.length > @list_length
  #     @list_length = @wednesday_replist3.length
  #   end
  #   if @wednesday_replist4.length > @list_length
  #     @list_length = @wednesday_replist4.length
  #   end
  #   if @thursday_replist1.length > @list_length
  #     @list_length = @thursday_replist1.length
  #   end
  #   if @thursday_replist2.length > @list_length
  #     @list_length = @thursday_replist2.length
  #   end
  #   if @thursday_replist3.length > @list_length
  #     @list_length = @thursday_replist3.length
  #   end
  #   if @thursday_replist4.length > @list_length
  #     @list_length = @thursday_replist4.length
  #   end
  #   if @friday_replist1.length > @list_length
  #     @list_length = @friday_replist1.length
  #   end
  #   if @friday_replist2.length > @list_length
  #     @list_length = @friday_replist2.length
  #   end
  #   if @friday_replist3.length > @list_length
  #     @list_length = @friday_replist3.length
  #   end
  #   if @friday_replist4.length > @list_length
  #     @list_length = @friday_replist4.length
    end
  end

  def rep_week
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
        # c.isr = override.isr
        # c.called = override.called
        # c.window = override.window
      end
    #   if c.rep.length > 0 && (!c.isr || c.isr == '' || c.isr == ' ')
    #     if c.rep != rep && rep.length > 0
    #       @weekhash.push({rep: rep, sun_1: sun_1, sun_2: sun_2, sun_3: sun_3, sun_4: sun_4, mon_1: mon_1, mon_2: mon_2, mon_3: mon_3, mon_4: mon_4, tue_1: tue_1, tue_2: tue_2, tue_3: tue_3, tue_4: tue_4, wed_1: wed_1, wed_2: wed_2, wed_3: wed_3, wed_4: wed_4, thu_1: thu_1, thu_2: thu_2, thu_3: thu_3, thu_4: thu_4, fri_1: fri_1, fri_2: fri_2, fri_3: fri_3, fri_4: fri_4, tot: tot})
    #       sun_1 = 0
    #       sun_2 = 0
    #       sun_3 = 0
    #       sun_4 = 0
    #       mon_1 = 0
    #       mon_2 = 0
    #       mon_3 = 0
    #       mon_4 = 0
    #       tue_1 = 0
    #       tue_2 = 0
    #       tue_3 = 0
    #       tue_4 = 0
    #       wed_1 = 0
    #       wed_2 = 0
    #       wed_3 = 0
    #       wed_4 = 0
    #       thu_1 = 0
    #       thu_2 = 0
    #       thu_3 = 0
    #       thu_4 = 0
    #       fri_1 = 0
    #       fri_2 = 0
    #       fri_3 = 0
    #       fri_4 = 0
    #       tot = 0
    #     end
    #     rep = c.rep
    #     tot += 1
    #     case c.callday
    #     when 'SUNDAY'
    #       case c.window
    #       when '10am - noon'
    #         sun_1 += 1
    #       when 'noon - 2pm'
    #         sun_2 += 1
    #       when '2pm - 4pm'
    #         sun_3 += 1
    #       else
    #         sun_4 += 1
    #       end
    #     when 'MONDAY'
    #       case c.window
    #       when '10am - noon'
    #         mon_1 += 1
    #       when 'noon - 2pm'
    #         mon_2 += 1
    #       when '2pm - 4pm'
    #         mon_3 += 1
    #       else
    #         mon_4 += 1
    #       end
    #     when 'TUESDAY'
    #       case c.window
    #       when '10am - noon'
    #         tue_1 += 1
    #       when 'noon - 2pm'
    #         tue_2 += 1
    #       when '2pm - 4pm'
    #         tue_3 += 1
    #       else
    #         tue_4 += 1
    #       end
    #     when 'WEDNESDAY'
    #       case c.window
    #       when '10am - noon'
    #         wed_1 += 1
    #       when 'noon - 2pm'
    #         wed_2 += 1
    #       when '2pm - 4pm'
    #         wed_3 += 1
    #       else
    #         wed_4 += 1
    #       end
    #     when 'THURSDAY'
    #       case c.window
    #       when '10am - noon'
    #         thu_1 += 1
    #       when 'noon - 2pm'
    #         thu_2 += 1
    #       when '2pm - 4pm'
    #         thu_3 += 1
    #       else
    #         thu_4 += 1
    #       end
    #     else
    #       case c.window
    #       when '10am - noon'
    #         fri_1 += 1
    #       when 'noon - 2pm'
    #         fri_2 += 1
    #       when '2pm - 4pm'
    #         fri_3 += 1
    #       else
    #         fri_4 += 1
    #       end
    #     end
    #   end
    end
    # @weekhash.push({rep: rep, sun_1: sun_1, sun_2: sun_2, sun_3: sun_3, sun_4: sun_4, mon_1: mon_1, mon_2: mon_2, mon_3: mon_3, mon_4: mon_4, tue_1: tue_1, tue_2: tue_2, tue_3: tue_3, tue_4: tue_4, wed_1: wed_1, wed_2: wed_2, wed_3: wed_3, wed_4: wed_4, thu_1: thu_1, thu_2: thu_2, thu_3: thu_3, thu_4: thu_4, fri_1: fri_1, fri_2: fri_2, fri_3: fri_3, fri_4: fri_4, tot: tot})
  end

  def list
    call_lists = CallList.all
    if !session[:called_isr] || session[:called_isr] == ''
      session[:called_isr] = ' '
    end
    @user = current_user.email.upcase
    $sunday_list = []
    $monday_list = []
    $tuesday_list = []
    $wednesday_list = []
    $thursday_list = []
    $friday_list = []
    call_lists.each do |c|
      override = OverrideCallList.find_by(custcode: c.custcode)
      today = Date.today
      if override.override_end >= today && override.override_start <= today
        # check if the override for this customer is active
        c.rep = override.rep
      end
      c.call_days.each do |d|
        if current_user.email == 'admin' || c.rep == current_user.email.upcase || d.isr == current_user.email.upcase
          if d.callback == ' '
            # no callback
            case d.callday
            when "SUNDAY"
              $sunday_list.push({calllist_id: c.id, callday_id: d.id, customer: c.custname, isr: d.isr})
            when "MONDAY"
              $monday_list.push({calllist_id: c.id, callday_id: d.id, customer: c.custname, isr: d.isr})
            when "TUESDAY"
              $tuesday_list.push({calllist_id: c.id, callday_id: d.id, customer: c.custname, isr: d.isr})
            when "WEDNESDAY"
              $wednesday_list.push({calllist_id: c.id, callday_id: d.id, customer: c.custname, isr: d.isr})
            when "THURSDAY"
              $thursday_list.push({calllist_id: c.id, callday_id: d.id, customer: c.custname, isr: d.isr})
            else
              $friday_list.push({calllist_id: c.id, callday_id: d.id, customer: c.custname, isr: d.isr})
            end
          else
            # callback in force
            case d.callback
            when "SUNDAY"
              $sunday_list.push({calllist_id: c.id, callday_id: d.id, customer: c.custname, isr: d.isr})
            when "MONDAY"
              $monday_list.push({calllist_id: c.id, callday_id: d.id, customer: c.custname, isr: d.isr})
            when "TUESDAY"
              $tuesday_list.push({calllist_id: c.id, callday_id: d.id, customer: c.custname, isr: d.isr})
            when "WEDNESDAY"
              $wednesday_list.push({calllist_id: c.id, callday_id: d.id, customer: c.custname, isr: d.isr})
            when "THURSDAY"
              $thursday_list.push({calllist_id: c.id, callday_id: d.id, customer: c.custname, isr: d.isr})
            else
              $friday_list.push({calllist_id: c.id, callday_id: d.id, customer: c.custname, isr: d.isr})
            end
          end
        end
      end
    end
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

    # Add sales rep to parameters
    def load_rep
      if call_list_params
        @cp = call_list_params
        if !@cp[:rep]
          @cp[:rep] = current_user.email.upcase
        end
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
      @alt_contact = [' ', 'ZINGLE', 'FAX', 'VOICE MAIL']
      @rep = []
      temprep = []
      calllist = CallList.all
      calllist.each do |c|
        if c.rep && !temprep.include?(c.rep)
          temprep.push(c.rep)
        end
      end
      @rep = temprep.sort
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
      @user = current_user.email.upcase
      @isr_user = false
      if @isr_list.include?(@user)
        @isr_user = true
      end
    end

    # Build a call list based on selected day and call window
    def build_call_list
      if !session[:called_day] || session[:called_day == '']
        # first time in
        session[:called_day] = 'SUNDAY'
        session[:called_window] = 'ALL'
      end
      @user = current_user.email.upcase
      @call_lists = []
      cls = CallList.all
      cls.each do |c|
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
        c.call_days.each do |d|
          # see if there are call day records for the current selections and user
          if ((d.callday == session[:called_day] && d.callback == ' ') || d.callback == session[:called_day]) && (d.window == session[:called_window] || session[:called_window] == 'ALL') && (@user == 'ADMIN' || @user == c.rep || @user == d.isr)
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
      @user = current_user.email.upcase
      @isr_user = false
      if @isr_list.include?(@user)
        @isr_user = true
      end
    end

    # After seven days reset the called flag to false.
    def reset_called_flag
      now = Date.today
      day_num = now.cwday
      case day_num
      when 0
        day_text = 'SUNDAY'
      when 1
        day_text = 'MONDAY'
      when 2
        day_text = 'TUESDAY'
      when 3
        day_text = 'WEDNESDAY'
      when 4
        day_text = 'THURSDAY'
      when 5
        day_text = 'FRIDAY'
      else
        day_text = 'SATURDAY'
      end
      a_week_ago = now - 6
      call_days = CallDay.all
      call_days.each do |c|
        if c.called && c.callday == day_text && (!c.date_called || c.date_called < now)
          c.called = 'NO'
          c.ordered = ' '
          c.callback = ' '
          c.alt_contact = ' '
          c.save
        end
      end
    end

    def update_call_list(isr_list, call_list)
      i = 0
      call_list.each do |c|
        d = CallDay.find(c[:callday_id])
        d.isr = isr_list[i]
        d.save
        i += 1
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
