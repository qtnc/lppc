local branches = {}

local readme
do local fp <close> = io.open('readme.md') 
readme = fp:read('a')
end

for m in readme:gmatch('\nBranch:%s+([%w_-]+)\r?\n') do
table.insert(branches, m)
end

local function exec (cmd)
return io.popen(cmd) :read('a')
end

exec('git checkout master')

for i, branch in ipairs(branches) do
exec('git checkout '..branch)
exec('git merge master')
local patchfile = branch..'.patch'
os.execute('git diff master >'..patchfile)
exec('git checkout master')
local stat = exec('git apply --stat '..patchfile) :match('\n([^\n]+)%s*$')
local escapedpatchfile = patchfile:gsub('([-.])', '%%%1')
readme = readme:gsub('(Download %[' .. escapedpatchfile .. '%])[ \t]*[^\n]+', '%1 (' .. stat .. ')')
end

do local fp <close> = io.open('readme.md', 'w')
fp:write(readme)
end

