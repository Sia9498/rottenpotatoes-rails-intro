class MoviesController < ApplicationController

    def show
      id = params[:id] # retrieve movie ID from URI route
      @movie = Movie.find(id) # look up movie by unique ID
      # will render app/views/movies/show.<extension> by default
    end
    
    def saveInSession(key, value)
      session["#{key}"] = value
    end
    
    def getFromSession(key)
      if isInSession(key)
        return session["#{key}"]
      end
    end
    
    def isInSession(key)
      return session.has_key?("#{key}")
    end
  
    def index
      
      @movies = Movie.all
      @unique_ratings = Movie.distinct('rating').pluck('rating')
      @selected_ratings = nil
      @selection = Movie
      
      if !params.has_key?('ratings') and !params.has_key?('sort_column') and (isInSession('sort_column') or isInSession('ratings'))
        paramsToPass = {}
        paramsToPass[:ratings] = getFromSession('ratings')
        paramsToPass[:sort_column] = getFromSession('sort_column')
        redirect_to movies_path(paramsToPass)
      end
      
      if params.has_key?('ratings')
        @selected_ratings = params[:ratings].keys
        @selection = Movie.where(rating: @selected_ratings)
        saveInSession('ratings', params[:ratings])
      elsif isInSession('ratings')
        @selected_ratings = getFromSession('ratings').keys
        @selection = Movie.where(rating: @selected_ratings)
      else
        @selected_ratings = @unique_ratings
      end
      
      if params.has_key?('sort_column') and Movie.column_names.include?(params[:sort_column])
        @sort_column = params[:sort_column]
        @movies = @selection.all.order("#{params[:sort_column]}")
        saveInSession('sort_column', params[:sort_column])
      elsif isInSession('sort_column')
        @movies = @selection.all.order("#{getFromSession('sort_column')}")
        @sort_column = "#{getFromSession('sort_column')}"
      else
        @movies = @selection.all
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
  
    private
    # Making "internal" methods private is not required, but is a common practice.
    # This helps make clear which methods respond to requests, and which ones do not.
    def movie_params
      params.require(:movie).permit(:title, :rating, :description, :release_date)
    end
  end