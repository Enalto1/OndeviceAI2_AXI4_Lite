# Build the Prompt 24 MicroBlaze standalone UART command app.
# Run with XSCT/Vitis 2020.2 after create_vitis_workspace.tcl.

set script_dir [file normalize [file dirname [info script]]]
set project_root [file normalize [file join $script_dir ".." ".."]]
set workspace_dir [file normalize [file join $project_root "sw" "vitis_workspace"]]
set platform_name "microblaze_axi_soc_platform"
set app_name "axi_soc_uart_app"
set elf_path [file normalize [file join $workspace_dir $app_name "Debug" "$app_name.elf"]]

puts "Project root: $project_root"
puts "Workspace: $workspace_dir"

if {![file isdirectory $workspace_dir]} {
    error "Vitis workspace directory not found: $workspace_dir"
}

setws $workspace_dir
platform active $platform_name
platform generate
app build -name $app_name

if {[file exists $elf_path]} {
    puts "ELF: $elf_path"
} else {
    puts "Build completed, but expected ELF path was not found: $elf_path"
}
