class CallDaysController < ApplicationController
  before_action :set_call_list, except: [:import]
  before_action :set_call_day, except: [:new, :create, :import]

  def new
    @call_day = CallDay.new
  end

  def edit
  end

  def create
    @call_day = CallDay.new(call_day_params)
    @call_day.save
    render action: 'show', status: :created, location:@call_list
  end

  def update
    @call_day.update(call_day_params)
  end

  def destroy
    @call_day.destroy
    redirect_to @call_list
  end

  def import
    CallDay.import(params[:file])
    redirect_to root_url, notice: "Call day imported."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_call_list
      @call_list = CallList.find(params[:call_list_id])
    end
    def set_call_day
      @call_day = CallDay.find(params[:id])
    end
    # Never trust parameters from the scary internet, only allow the white list through.
    def call_day_params
      params.require(:call_day).permit(:call_list_id, :callday, :notes, :isr, :called, :date_called, :ordered, :date_ordered, :callback, :callback_date, :window)
    end
end
