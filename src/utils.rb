class RenameRoutineError  < StandardError; end      #code bug
class RenameStandardError < RenameRoutineError; end #この例外を補足する

ERROR_MESSAGE = {
  enough:  "Not enough arguments",
  many:    "Too many arguments",
  onlyone: "can be specified rename-option is only one"
}

HELP_MESSAGE = {
  replace: "replace before to after. The after's defult value is empty string",
}

def error(message, num)
  warn "error: #{message}"
  exit(num)
end

def goodbye(message)
  puts message
  exit(0)
end
