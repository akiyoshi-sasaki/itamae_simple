
include_recipe "../cookbooks/default.rb"

include_recipe "../cookbooks/setup_secret.rb"

include_recipe "../cookbooks/mysql/mysql.rb"
