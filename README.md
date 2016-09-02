# Learning by Doing

![Ubuntu version](https://img.shields.io/badge/Ubuntu-16.04%20LTS-orange.svg)
![Rails version](https://img.shields.io/badge/Rails-v5.0.0-blue.svg)
![Ruby version](https://img.shields.io/badge/Ruby-v2.3.1p112-red.svg)


# Singer
A rails web app that can integrate the songs on the youtube and the songs on the soundcloud with the lyrics.


# Create a App
```console
$ rails new singer
```

# Add some rubygems we're going to use
In Gemfile
```console
gem 'therubyracer'
gem 'haml', '~>4.0.5'
gem 'bootstrap-sass', '~> 3.2.0.2'
gem 'simple_form', github: 'kesha-antonov/simple_form', branch: 'rails-5-0'
gem 'link_thumbnailer'
gem 'cocoon', '~> 1.2.6'
```
Note: 
Because there is no Javascript interpreter for Rails on Ubuntu Operation System, we have to install `Node.js` or `therubyracer` to get the Javascript interpreter.


# CRUD
A song has many links and has many lyrics.          
To get start it, let's go ahead and create a song controller.
```console
$ rails g controller songs
```

In addition to our controller, we're gonna to need some routes. Under `app/config/routes.rb`
```ruby
Rails.application.routes.draw do
	resources :songs

	root "songs#index"
end
```

Create a new song

Let's go ahead and create the ability to add our new songs and show our songs.

Under `app/controllers/songs_controller.rb`
```ruby
class SongsController < ApplicationController
	before_action :find_song, only: [:show, :edit, :update, :destroy]

    def index
    	@song = Song.all.order("created_at DESC")
    end

    def show
    end

    def new
    	@song = Song.new
    end

    def create
    	@song = Song.new(song_params)
    	if @song.save
    		redirect_to @song, notice: "Successfully created new song"
    	else
    		render 'new'
    	end
    end

    def edit
    end

    def update
        if @song.update(song_params)
            @song.links.each do |link|
                object = LinkThumbnailer.generate(link.link)
                link.title = object.title
                link.favicon = object.favicon
                link.description = object.description
                link.image = object.images.first.src.to_s
                link.save
            end            
            redirect_to @song
        else
            render 'edit'
        end
    end

    def destroy
        @song.destroy
        redirect_to root_path, notice: "Successfully delted song"
    end     

    private

    def song_params
        params.require(:song).permit(:title, links_attributes: [:id, :link, :embed, :_destroy])
    end    

    def find_song
        @song = Song.find(params[:id])
    end

    def find_link
        @link = Link.find(params[:id])
    end
    
    def link_params
        params.require(:link).permit(:link, :embed)
    end    
end
```

Then we need to create our song model.
```console
$ rails g model Song title:string description:text user_id:integer
$ rake db:migrate
```


In `app/views/songs`, let's create some file
1. _new_form.html.haml
2. _edit_form.html.haml
3. new.html.haml
4. edit.html.haml
5. show.html.haml

In `app/views/songs/_form.html.haml`
```haml
= simple_form_for @song, html: { multipart: true } do |f|
	= f.input :title, input_html: { class: 'form-control' }
	= f.button :submit, class: "btn btn-primary"
```

In `app/views/songs/new.html.haml`
```haml
%h1 New Song

= render 'form'

%br/

=link_to "Back", root_path, class: "btn btn-default"
```

In `app/views/songs/edit.html.haml`
```haml
%h1 Edit Song

= render 'form'

%br/

=link_to "Back", root_path, class: "btn btn-default"
```


In `app/views/songs/index.html.haml`
```haml
- @song.each do |song|
	%h2= link_to song.title, song
=link_to "New", new_song_path, class: "btn btn-default"
```

In `app/views/songs/show.html.haml`
```haml
%h1= @song.title
%p= simple_format @song.description

%h2 Links
%ul
	- @song.links.each do |link|   
		%li= link.title
		%li= link.description
		%li= image_tag link.image
		%li= link.link
		%li= link.embed

=link_to "Back", root_path, class: "btn btn-default"
=link_to "Edit", edit_song_path, class: "btn btn-default"
=link_to "Delete", song_path, method: :delete, data: {confirm: "Are you sure?"}, class: "btn btn-default"
```



# Cacoon

Then, let's add cacoon         
So in `app/assets/application.js`, we add `//= require cocoon` so it compiles to the asset pipeline.
```js
//= require jquery
//= require jquery_ujs
//= require cocoon
//= require turbolinks
//= require_tree 
```

Let's generate the link model.
```console
$ rails g model Link title:string link:string favicon:string description:text image:string embed:string song_id:integer song:belongs_to
$ rake db:migrate
```

Then in `app/models/song.rb`
```ruby
class Song < ApplicationRecord
	has_many :links
	accepts_nested_attributes_for :links, reject_if: :all_blank, allow_destroy: true
end
```


Now we want a song form where we can add and remove links dynamically. To do this, we need the fields for a new or existing link to be defined in a partial named _link_fields.html.haml.

In our `app/views/songs/_new_form.html.haml` partial we'd write:
```haml
= simple_form_for @song, html: { multipart: true } do |f|
	- if @song.errors.any?
		#errors
			%p
				= @song.errors.count
				Prevented this song froms saving
			%ul
				- @song.errors.full_messages.each do |msg|
					%li= msg
	= f.input :title, input_html: { class: 'form-control' }
	= f.button :submit, class: "btn btn-primary"

= link_to "Back", root_path, class: "btn btn-default"
```

In our `app/views/songs/_edit_form.html.haml` partial we'd write:
```haml
= simple_form_for @song, html: { multipart: true } do |f|
	- if @song.errors.any?
		#errors
			%p
				= @song.errors.count
				Prevented this song froms saving
			%ul
				- @song.errors.full_messages.each do |msg|
					%li= msg
	= f.input :title, input_html: { class: 'form-control' }
	%h3 Links
	= f.simple_fields_for :links do |link|
		= render 'link_fields', f: link
	.links
		= link_to_add_association 'add link', f, :links	
	= f.button :submit, class: "btn btn-primary"

= link_to "Back", root_path, class: "btn btn-default"
```


In our `app/views/songs/_link_fields.html.haml`
```haml
.nested-fields
	= f.input :link, input_html: { class: 'form-input form-control' }
	= f.input :embed, input_html: { class: 'form-input form-control' }
	= link_to_remove_association "remove link", f, class: "form-button btn btn-default"
```


# Masonry

Masonry is a light-weight layout framework which wraps AutoLayout with a nicer syntax.          

https://github.com/kristianmandrup/masonry-rails

Let's go to our Gemfile, we need a gem called masonry-rails.            
In Gemfile, we add this line, run bundle install and restart the server.
```console
gem 'masonry-rails', '~> 0.2.1'
```

In app/assets/javascripts/application.js, under jquery, we add `//= require masonry/jquery.masonry`
```js
//= require jquery
//= require jquery_ujs
//= require masonry/jquery.masonry
//= require bootstrap-sprockets
//= require cocoon
//= require turbolinks
//= require_tree .
```

To get this work, I'm going to add some styling and coffescript. In app/assets/javascripts/pin.coffee
```coffee
$ ->
  $('#songs').imagesLoaded ->
    $('#songs').masonry
      itemSelector: '.box'
      isFitWidth: true
```

In our app/views/songs/index.html.haml, we need to add:
```haml
#songs.transitions-enabled
	- @song.each do |song|
		.box.panel.panel-default
			- if song.links.present?
				=link_to (image_tag song.links.first.image, height: '250', width: '350'), song
			- else
				=link_to song.title, song
			.panel-body
				%h2= link_to song.title, song
=link_to "New", new_song_path, class: "btn btn-default"
```

### Basic Styling
And in `app/assets/stylesheets/application.css.scss`
```scss
/*
 * This is a manifest file that'll be compiled into application.css, which will include all the files
 * listed below.
 *
 * Any CSS and SCSS file within this directory, lib/assets/stylesheets, vendor/assets/stylesheets,
 * or any plugin's vendor/assets/stylesheets directory can be referenced here using a relative path.
 *
 * You're free to add application-wide styles to this file and they'll appear at the bottom of the
 * compiled file so the styles you add here take precedence over styles defined in any other CSS/SCSS
 * files in this directory. Styles in this file should be added after the last require_* statement.
 * It is generally better to create a new file per style scope.
 *
 *= require_tree .
 *= require_self
 */

#songs {
  margin: 0 auto;
  width: 100%;
  .box {
      margin: 10px;
      width: 350px;
      box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.22);
      border-radius: 7px;
      text-align: center;
      text-decoration:none;
      img {
        max-width: 100%;
        height: 250px;
      }
      h2 {
        font-size: 22px;
        margin: 0;
        padding: 20px 10px;
        a {
                color: #474747;
                text-decoration:none;
        }
      }
    }
}

textarea {
    min-height: 250px;
}
```





