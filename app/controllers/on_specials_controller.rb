class OnSpecialsController < ApplicationController
  before_action :set_on_special, only: [:show, :edit, :update, :destroy]

  # GET /on_specials
  def index
    @on_specials = OnSpecial.all
  end

  # GET /on_specials/1
  def show
  end

  # GET /on_specials/new
  def new
    @new_onspecial = true
    build_lists
    @on_special = OnSpecial.new
  end

  # GET /on_specials/1/edit
  def edit
    @new_onspecial = false
    build_lists
  end

  # POST /on_specials
  def create
    if on_special_params[:customer] == 'ALL'
      authorlists = Authorlist.all
      authorlists.each do |a|
        if onspecial_params[:part] == a.partcode
          op = onspecial_params
          op[:customer] = a.custcode
          @onspecial = Onspecial.new(op)
          @onspecial.save
        end
      end
      redirect_to action: "index", notice: 'Onspecials were successfully created.'
    else
      @on_special = OnSpecial.new(on_special_params)

      respond_to do |format|
        if @on_special.save
          format.html { redirect_to @on_special, notice: 'On special was successfully created.' }
        else
          format.html { render :new }
        end
      end
    end
  end

  # PATCH/PUT /on_specials/1
  def update
    if on_special_params[:customer] == 'ALL'
      authorlists = AuthorList.all
      authorlists.each do |a|
        if on_special_params[:part] == a.partcode
          op = on_special_params
          op[:customer] = a.custcode
          @on_special.update(op)
        end
      end
      redirect_to action: "index", notice: 'On specials were successfully created.'
    else
      respond_to do |format|
        if @on_special.update(on_special_params)
          format.html { redirect_to @on_special, notice: 'On special was successfully updated.' }
        else
          format.html { render :edit }
        end
      end
    end
  end

  # DELETE /on_specials/1
  def destroy
    @on_special.destroy
    respond_to do |format|
      format.html { redirect_to on_specials_url, notice: 'On special was successfully destroyed.' }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_on_special
      @on_special = OnSpecial.find(params[:id])
    end

    # Build lists of current customers and parts
    def build_lists
      @customer = []
      @part = []
      @allcust = []
      @allpart = []

      if @new_onspecial
        cust = 'ALL'
      else
        cust = @on_special.customer
      end

      tempcust = []
      temppart = []
      authorlist = AuthorList.all
      authorlist.each do |a|
        if (cust =='ALL' || a.custcode == cust) && !temppart.include?(a.partcode)
          temppart.push(a.partcode)
        end
        @allcust.push(a.custcode)
        @allpart.push(a.partcode)
      end

      calllist = CallList.all
      calllist.each do |c|
        if !tempcust.include?(c.custcode)
          tempcust.push(c.custcode)
        end
        @allcust.push(c.custcode)
      end
      @customer = tempcust.sort
      if @new_onspecial
        @customer.insert(0,'ALL')
      end
      @part = temppart.sort
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def on_special_params
      params.require(:on_special).permit(:customer, :part, :onspecials_start, :onspecials_end)
    end
end
