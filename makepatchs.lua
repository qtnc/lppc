local branches = {}
local patchs = {}

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
os.execute('git diff master >temp.patch')
exec('git checkout master')
local stat = exec('git apply --stat temp.patch') :match('\n[ \t]*([^\n]+)%s*$')
local escapedpatchfile = patchfile:gsub('([-.])', '%%%1')
readme = readme:gsub('(Download %[' .. escapedpatchfile .. '%]%(' .. escapedpatchfile .. '%))[ \t]*[^\n]+', '%1 (' .. stat .. ')')
do local fp <close> = io.open('temp.patch')
patchs[patchfile] = fp:read('a')
end end

for patchfile, patch in pairs(patchs) do
local fp <close> = io.open(patchfile, 'w')
fp:write(patch)
end

do local fp <close> = io.open('readme.md', 'w')
fp:write(readme)
end

os.remove('temp.patch')


