{exec} = require "child_process"

# Clean the environment
task "clean", "Clean the environment.", ->
	exec "rm -rf *.js; rm -rf src/modules/*.js; rm -rf src/tools/*.js", (err, stdout, stderr) ->
		throw err if err
		console.log stdout + stderr
		console.log "All .js files were removed."
	exec "rm -rf node_modules", (err, stdout, stderr) ->
		throw err if err.configure
		console.log stdout + stderr
		console.log "node_modules folder was removed."