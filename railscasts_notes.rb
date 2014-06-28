# ACTION ITEMS:
# [5] Research Rails 4 scopes and how to pass in a hash of options or a single variable, such as an integer

# EPISODE 1
# If you're making a database call, it's much faster to call it once with
# an OR operator
@current_user ||= User.find(session[:user_id])


# EPISODE 2
# This episode is deprecated as of Rails 4. Previously, could do
Model.find_first_by_codename("Justice League")
# Now it's:
Model.where(codename: "Justice League")
# Good reference: http://blog.remarkablelabs.com/2012/12/what-s-new-in-active-record-rails-4-countdown-to-2013


# EPISODE 3
# EPISODE 4


# EPISODE 5
# Using scopes is a better way to organize database calls and are defined in the model
# Instead of having:
class Shirt < ActiveRecord::Base
  def self.red
    where(color: 'red')
  end
end
# You can have:
class Shirt < ActiveRecord::Base
  scope :red, -> { where(color: 'red') }
end


# EPISODE 6
# Symbol to_proc is a shorter syntax for:
projects.collect { |p| p.name }
# Using Symbol to_proc, simply:
projects.collect(&:name)
# Symbol to_proc is best used when it's a single method being called on the object.
# However, it is possible to string the methods. Here's two Symbol to_proc's:
projects.collect(&:name).collect(&:downcase)
# It can be used on any method that takes a block.


# EPISODE 7
# Similar to when you have an application.html.erb in app/views/layout, which is the default
# layout, you can change it to whatever. You can change it on a controller level (ex: users controller)
# by creating app/views/layout/users.html.erb
# Some now deprecated code for layouts include:
class PostsController < ApplicationController
	layout "users"					# If you want your posts controller to reference a different layout
	layout :dynamic_layout	# If you want a conditional-based layout -- see method below

	def index
		@posts = Posts.all
	end

	protected

	def dynamic_layout
		if some_truthy_value
			"admin"
		else
			false								# This will set layout to false, which applies no layouts
		end
	end
end
# Rails 4 users render. Reference:
# http://guides.rubyonrails.org/layouts_and_rendering.html


# EPISODE 8
# This talks about how you can pull in specific CSS files. Rails 4 guide does not explain everything
# so refer to:
# http://stackoverflow.com/questions/16386545/controller-specific-stylesheets-in-rails-3-inheritence


# EPISODE 9
# Without password digest, Ruby stores the user's password and credit card info as plain text in the
# logs. To stop this, you put in controllers/application.rb:
filter_parameter_logging "password"
# This won't stop it from showing up on the SQL portions of the dev logs, but typically prod logs do
# not show SQL entries.


# EPISODE 10
# EPISODE 11


# EPISODE 12
# If you have have duplication in your tests, specifically when setting up variables and instances, you
# can create a method to assist in removal of dup.


# Episode 13
# Make sure you never store model information in a session. You should always call:
@user = User.find(params[:id])
# Rather than:
session[:user] = User.find(params[:id])
# If you save it to the session, then any changes made to the session are not stored in the database.
# Always fetch it by user_id.
# Only store arrays, hashes, integers, constants in sessions.


# EPISODE 14
# ActiveRecord provides simple SQL calculations that are better peformance-wise than loading them into
# Ruby, then calculating it there. For example:
Task.average(:priority)
# Can also add conditions:
Task.average(:priority, condition: "complete=0")


# EPISODE 15


# EPISODE 16
# If you want a field on your form that's not in the database, you can use a virtual attribute.
# For example, if your database has First Name and Last Name, but you want your form to have
# one field for Full Name, you set the form in the view to:
# <%= f.text_field :full_name %>
# Then in the User model, define a getter and setter method:
def full_name
	[first_name, last_name].join(' ')
end

def full_name=(name)
	split = name.split(' ', 2)
	self.first_name = split.first
	self.last_name = split.last
end
# Now if you save it, it will save first_name and last_name separtely.


# EPISODE 17
# If you have a has_many_and_belongs_to assocation, you can easily setup checkboxs with this in the view:
# Note: This is old code and instead each should be called.
# <% for category in Category.find(:all) %>
# <div>
#   <%= check_box_tag "product[category_ids][]", category.id, @product.categories.include?(category) %>
#   <%= category.name %>
# </div>
# <% end %>
# And in the controller:
def update
  params[:product][:category_ids] ||= []
  #...
end
# Without this params line, it's not possible to remove all categories.


# EPISODE 18
# EPISODE 19


# EPISODE 20
# If you have a method defined in a controller (such as application.rb) and want it to be usable
# in the view as well, write:
helper_method :method_name


# EPISODE 21


# EPISODE 22 -- Eager Loading
# Lets say you had a list of products that had a category and price. To auto-load category change from:
@product = Product.order("name") # to
@product = Product.order("categories.name").joins(:category).select("products.*, categories.name as category_name")
# The select portion tells what to return from the database call. This way it doesn't pull in too much info.
# Then in the view, instead of:
product.category.name # it's now
product.category_name
# If you want to be notified when to use eager loading, check out the bullet gem -- https://github.com/flyerhzm/bullet
# which is discussed more in episode 372


# EPISODE 23 -- Counter Cache Column
# Instead of calling task size in the view like:
project.tasks.size
# Can generate a column in the Project model called tasks_count (naming is very important)
# The migration then has:
add_column :projects, :tasks_count, :integer, :default => 0

Project.reset_column_information
Project.find(:all).each do |p|
  Project.update_counters p.id, :tasks_count => p.tasks.length
end
# Then in the task.rb model file:
belongs_to :project, :counter_cache => true


# EPISODE 24 -- Stack Trace


# EPISODE 25 -- SQL Injection
# Be concerned of anything in the params hash and cookies hash. The user has complete control over those two.
# Example of bad code:
@tasks = Task.find(:all,:conditions=>"name LIKE '#{params[:query]}'")
# If this was used in a search field, the user could search for hey' test   and that word test is directly accessing
# the database. Replace test with delete.* and everything's gone. Better code:
@tasks = Task.find(:all,:conditions=> ["name LIKE ?", '%' + params[:query] + '%']) # %'s allow for partial search


# EPISODE 26 -- Hackers Love Mass Assignment
# If your User model has a boolean for admin and your view doesn't have an admin field to toggle it, it does NOT mean
# you're safe. Users can send any info they want in the params. They can right-click, inspect element, change
# a field name from user[name] to user[admin], type in 1, then submit. Boom, they're an admin.
# Rails 4 limits what params are OK to go through. Look at the private methods in any controller.


# EPISODE 27 -- Cross Site Scripting
# This happens when you do not escape HTML from text fields. Not preventing this allows users to input <script> tags,
# which can be both annoying and dangerous. They could have the script send session ids to their own site and then
# steal their identity.
# Can prevent this by escaping HTML in the view via h method:
h(comment.content)
# Or escape it in the controller create/update action:
CGI::escape_html(params[:comment])


# EPISODE 28 -- in_groups_of
a = (1..12).to_a
a.in_groups_of(4) # => [[1,2,3,4], [5,6,7,8], ...]
a.in_groups_of(7, false) # => If not divisible by 7, will fill the remainding spaces with false


# EPISODE 29 -- group_by Month
a = (1..20).to_a
a.group_by { |num| num/5 } # => {0=>[1, 2, 3, 4], 1=>[5, 6, 7, 8, 9], 2=>[10, 11, 12, 13, 14], 3=>[15, 16, 17, 18, 19], 4=>[20]}
@task_months = @tasks.group_by { |t| t.due_at.beginning_of_month }
# The in the view... note: have to do this hack since hashes aren't organized
<% @task_months.keys.sort.each do |month| %> 
	<% for task in @task_months[month] %>


# EPISODE 30 -- Pretty Page Title
# As discussed in Hartl's guide, you can add to application_helper.rb:
def title(page_title)
	content_for(:title) { page_title }
end
# In application layout:
<title>Shoppery - <%= yield(:title) || "The Place to Buy Stuff" %></title>
# Hartl's guide does this in a better way


# EPISODE 31 -- Formatting Time
# Some basic ways:
task.due_at.to_s(:short) # Can also do long, db, etc
# One way to format time into a standard way:
task.due_at.strftime("due on %B %d at %I:%M %p")
# If you want to reuse it, can add it and use it like the above example. In config/environments.rb:
Time::DATE_FORMATS[:due_time] = "due on %B %d at %I:%M %p"
# Then call it in the view:
task.due_at.to_s(:due_time)


# EPISODE 32 -- Time in Text Field
# Rails provide a DateTime selector method for user input of time. Another alternative is to use a
# text_field then create a virtual attribute
# <label for="task_due_at">Due at:</label><br />
# <%= f.text_field :due_at_string %>
# Create getter and setter method in the model
def due_at_string
	due_at.to_s(:db)
end
def due_at_string=(due_at_str)
	self.due_at = Time.parse(due_at_str)
rescue ArgumentError
	@due_at_invalid = true
end

def validate
	errors.add(:due_at, "is invalid") if @due_at_invalid
end
# Parse method is quite flexible.
# Can also use the Chronic gem, which will allow you to say "Next Monday at 8:00"
# If you put in an invalid date, get an ugly error. Fix is the rescue above.

