require 'sinatra'
require 'sqlite3'
require 'slim'
enable :sessions

get('/') do
    slim(:home)
end

get('/login') do
    slim(:login)
end

# loginpost

get('/signup') do
    slim(:signup)
end

# signuppost

