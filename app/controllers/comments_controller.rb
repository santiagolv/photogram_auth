class CommentsController < ApplicationController
  def index
    @comments = Comment.all

    render("comments/index.html.erb")
  end

  def show
    @comment = Comment.find(params[:id])

    render("comments/show.html.erb")
  end

  def new
    @comment = Comment.new

    render("comments/new.html.erb")
  end

  def create
    @comment = Comment.new

    @comment.photo_id = params[:photo_id]
    @comment.body = params[:body]
    @comment.user_id = params[:user_id]

    save_status = @comment.save

    if save_status == true
      redirect_to("/comments/#{@comment.id}", :notice => "Comment created successfully.")
    else
      render("comments/new.html.erb")
    end
  end

  def edit
    @comment = Comment.find(params[:id])

    render("comments/edit.html.erb")
  end

  def update
    @comment = Comment.find(params[:id])

    @comment.photo_id = params[:photo_id]
    @comment.body = params[:body]
    @comment.user_id = params[:user_id]

    save_status = @comment.save

    if save_status == true
      redirect_to("/comments/#{@comment.id}", :notice => "Comment updated successfully.")
    else
      render("comments/edit.html.erb")
    end
  end

  def destroy
    @comment = Comment.find(params[:id])

    @comment.destroy

    if URI(request.referer).path == "/comments/#{@comment.id}"
      redirect_to("/", :notice => "Comment deleted.")
    else
      redirect_to(:back, :notice => "Comment deleted.")
    end
  end
end
