class PostsController < ApplicationController
  before_filter :authenticate_user!
  # GET /posts
  # GET /posts.json
  def index
    @posts = current_user.posts

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @posts }
    end
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
    @post = Post.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @post }
    end
  end

  # GET /posts/new
  # GET /posts/new.json
  def new
    @post = Post.new(:parent_id => params[:parent])


    # -------------- mechanize
    agent = Mechanize.new
    agent.user_agent_alias = 'Mac Safari'
    page = agent.get("http://www.google.com/")
    search_form = page.forms_with(:name=>"f").first
    search_form.q = "Hello"
    search_results = agent.submit(search_form)
    rez = search_results.body

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @post }
    end
  end

  # GET /posts/1/edit
  def edit
    @post = Post.find(params[:id])
  end

  # POST /posts
  # POST /posts.json
  def create

    @post = current_user.posts.new(params[:post])


    respond_to do |format|
        if (params[:post][:parent] ? (Post.find(params[:post][:parent]).add_child @post) : @post.save)
        case current_user.provider
          when 'facebook' then FbGraph::User.me(session['fb_access_token']).feed!(:message => @post.body)
          when 'twitter' then current_user.post_tweets(@post.body)
        end



        format.html { redirect_to @post, notice: 'Post was successfully created.' }
        format.json { render json: @post, status: :created, location: @post }
      else
        format.html { render action: "new" }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /posts/1
  # PUT /posts/1.json
  def update
    @post = Post.find(params[:id])

    respond_to do |format|
      if @post.update_attributes(params[:post])
        format.html { redirect_to @post, notice: 'Post was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post = Post.find(params[:id])
    @post.destroy

    respond_to do |format|
      format.html { redirect_to posts_url }
      format.json { head :no_content }
    end
  end
end
