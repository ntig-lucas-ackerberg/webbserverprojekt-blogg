require 'sinatra'
require 'sqlite3'
require 'slim'
require 'bcrypt'
enable :sessions

get('/') do
    db = SQLite3::Database.new('db/db.db')
    db.results_as_hash = true
    blogposts = db.execute("SELECT Användare.Namn, post.id, posttitle, posttext, authorid FROM post INNER JOIN Användare on Användare.Id = post.authorid")
    slim(:home, locals:{blogposts: blogposts})
end

get('/login') do
    slim(:login)
end

get('/newpost') do
    slim(:newpost)
end

post('/login') do
    db = SQLite3::Database.new("db/db.db")
    db.results_as_hash = true
    password = db.execute('SELECT Lösenord, Id FROM Användare WHERE Namn=?', params["Username"])
    if password != []
        if (BCrypt::Password.new(password[0][0]) == params["Password"]) == true
            session[:username] = params["Username"]
            session[:id] = password[0]["Id"]
            redirect('/')
        else
            redirect('/loginfail')
        end
    else
        redirect('/loginfail')
    end
end

get('/loginfail') do
    slim(:loginfail)
end

get('/profile/:id') do
    db = SQLite3::Database.new('db/db.db')
    db.results_as_hash = true
    blogposts = db.execute("SELECT id, authorid, posttitle, posttext FROM post WHERE authorid=?" ,params["id"])
    slim(:profile, locals:{blogposts: blogposts})
end

post('/newpost') do
    db = SQLite3::Database.new('db/db.db')
    db.execute("INSERT INTO post(posttitle, posttext, authorid ) VALUES (?,?,?)",params["posttitle"],params["posttext"],session[:id])
        redirect("/profile/#{session[:id]}")
end

get('/editprofile') do
    slim(:editprofile)
end

post('/editprofile') do
    db = SQLite3::Database.new('db/db.db')
    db.execute("UPDATE Användare SET Namn = ? WHERE id = ?",params["Username"], session[:id])
    session[:username] = params["Username"]
    redirect("/profile/#{session[:id]}")
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

get('/edit/:id') do 
    db = SQLite3::Database.new('db/db.db')
    db.results_as_hash = true
    result = db.execute("SELECT id, posttitle, posttext FROM post WHERE id = ?",params["id"])
    p params["id"]
    p result
    slim(:editpost, locals:{result: result})
end

post('/edit/:id/update') do 
    db = SQLite3::Database.new('db/db.db')
    db.execute("UPDATE post SET posttitle = ?,posttext = ? WHERE id = ?",params["posttitle"],params["posttext"],params["id"])
    redirect("/profile/#{session[:id]}")
end

post('/:id/delete') do
    db = SQLite3::Database.new("db/db.db")
    db.execute("DELETE FROM post WHERE id = (?)", params["id"])
    redirect("/profile/#{session[:id]}")
end

