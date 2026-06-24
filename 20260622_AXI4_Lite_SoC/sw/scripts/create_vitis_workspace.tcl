# Create the Vitis 2020.2 workspace, standalone platform, BSP, and empty app.
# Run with XSCT/Vitis 2020.2 from the project root or through create_and_build_software.bat.

set script_dir [file normalize [file dirname [info script]]]
set project_root [file normalize [file join $script_dir ".." ".."]]
set workspace_dir [file normalize [file join $project_root "sw" "vitis_workspace"]]
set src_dir [file normalize [file join $project_root "sw" "src"]]
set xsa_path [file normalize [file join $project_root "vivado" "basys3" "microblaze_axi_soc" "exports" "microblaze_axi_soc.xsa"]]
set platform_name "microblaze_axi_soc_platform"
set domain_name "standalone_domain"
set app_name "axi_soc_uart_app"
set proc_name "microblaze_0"

puts "Project root: $project_root"
puts "Workspace: $workspace_dir"
puts "XSA: $xsa_path"

if {![file exists $xsa_path]} {
    error "Required XSA not found: $xsa_path"
}
if {![file isdirectory $src_dir]} {
    error "Source directory not found: $src_dir"
}

file mkdir $workspace_dir
setws $workspace_dir

# Recreate only the Vitis workspace objects. Project-owned source files stay in sw/src.
if {[file exists [file join $workspace_dir $app_name]]} {
    file delete -force [file join $workspace_dir $app_name]
}
if {[file exists [file join $workspace_dir $platform_name]]} {
    file delete -force [file join $workspace_dir $platform_name]
}

platform create -name $platform_name -hw $xsa_path -out $workspace_dir -proc $proc_name -os standalone
platform active $platform_name

if {[catch {domain active $domain_name}]} {
    domain create -name $domain_name -os standalone -proc $proc_name
    domain active $domain_name
}

platform generate
app create -name $app_name -platform $platform_name -domain $domain_name -template "Empty Application"

set app_src_dir [file join $workspace_dir $app_name "src"]
file mkdir $app_src_dir
foreach pattern {*.c *.h} {
    foreach src_file [glob -nocomplain -directory $src_dir $pattern] {
        file copy -force $src_file $app_src_dir
    }
}

puts "Created Vitis workspace objects. Run build_software.tcl to build the ELF."

