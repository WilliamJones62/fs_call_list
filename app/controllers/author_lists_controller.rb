class AuthorListsController < ApplicationController
  before_action :set_author_list, only: [:show, :edit, :update, :destroy]

  # GET /author_lists
  # GET /author_lists.json
  def index
    @author_lists = AuthorList.all
  end

  # GET /author_lists/1
  # GET /author_lists/1.json
  def show
  end

  # GET /author_lists/new
  def new
    @author_list = AuthorList.new
  end

  # GET /author_lists/1/edit
  def edit
  end

  # POST /author_lists
  # POST /author_lists.json
  def create
    @author_list = AuthorList.new(author_list_params)

    respond_to do |format|
      if @author_list.save
        format.html { redirect_to @author_list, notice: 'Author list was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /author_lists/1
  # PATCH/PUT /author_lists/1.json
  def update
    respond_to do |format|
      if @author_list.update(author_list_params)
        format.html { redirect_to @author_list, notice: 'Author list was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /author_lists/1
  # DELETE /author_lists/1.json
  def destroy
    @author_list.destroy
    respond_to do |format|
      format.html { redirect_to author_lists_url, notice: 'Author list was successfully destroyed.' }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_author_list
      @author_list = AuthorList.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def author_list_params
      params.require(:author_list).permit(:partcode, :dept, :custcode, :turns, :seq, :priority)
    end
end
