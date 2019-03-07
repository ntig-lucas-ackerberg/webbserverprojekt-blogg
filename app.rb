require 'sinatra'
require 'sqlite3'
require 'slim'
require 'bcrypt'
enable :sessions

get('/') do
    slim(:home)
end

get('/login') do
    slim(:login)
end

get('/profile') do
    slim(:profile)
end

get('/profile') do
    db = SQLite3::Database.new('db/db.db')
    db.results_as_hash = true
    blogposts = db.execute("SELECT authorid, posttitle, posttext FROM post WHERE postid=?") , 2
    slim(:profile, locals:{blogposts: blogposts})
end

get('/newpost') do
    slim(:newpost)
end

post('/newpost') do
    db = SQLite3::Database.new('db/db.db')
    db.execute("INSERT INTO post(posttitle, posttext, authorid ) VALUES (?,?,?)",params["posttitle"],params["posttext"],2)
        redirect('/profile')
end

post('/login') do
    db = SQLite3::Database.new("db/db.db")
    db.results_as_hash = true
    password = db.execute('SELECT Lösenord FROM Användare WHERE Namn=?', params["Username"])
    if password != []
        if (BCrypt::Password.new(password[0][0]) == params["Password"]) == true
            session[:username] = params["Username"]
            redirect('/')
        else
            redirect('/loginfail')
        end
    else
        redirect('/loginfail')
    end
end

get('/signup') do
    slim(:signup)
end

post('/logout') do
    session[:username] = nil
    session[:password] = nil
    session.destroy
    redirect('/')
end

post('/signup') do
    db = SQLite3::Database.new("db/db.db")
    db.results_as_hash = true
    if params["Username"] != "" && params["Password"]
        db.execute('INSERT INTO Användare(Namn, Lösenord) VALUES (?, ?)', params["Username"], BCrypt::Password.create(params["Password"]))
        redirect('/login')
    else
        redirect('/signup')
    end
end

