class MoviesController < ApplicationController
  helper_method :chosen_rating?

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.ratings      
    @sort_by = params[:sort_by]
    session[:ratings] = params[:ratings] unless params[:ratings].nil?
    session[:sort_by] = params[:sort_by] unless params[:sort_by].nil?

    if (params[:ratings].nil? && !session[:ratings].nil?) || (params[:sort_by].nil? && !session[:sort_by].nil?)
      redirect_to movies_path(:ratings => session[:ratings], :sort_by => session[:sort_by])
    elsif !params[:ratings].nil? || !params[:sort_by].nil?
      if !params[:ratings].nil?
        array_ratings = params[:ratings].keys
        return @movies = Movie.where(rating: array_ratings).order(session[:sort_by])
      else
        return @movies = Movie.all.order(session[:sort_by])
      end
    elsif !session[:ratings].nil? || !session[:sort_by].nil?
      redirect_to movies_path(:ratings => session[:ratings], :sort_by => session[:sort_by])
    else
      return @movies = Movie.all
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end
  
  def chosen_rating?(rating)
    chosen_ratings = session[:ratings]
    return true if chosen_ratings.nil?
    chosen_ratings.include? rating
  end

end
