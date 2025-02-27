#!/usr/bin/env ruby

# Use to identify differences between dear imgui's API and ReaImGui's API
# This tool also performs various sanity checks on the exported API

IMGUI_H = File.join __dir__, '..', 'vendor', 'imgui', 'imgui.h'
REAIMGUI_API_CPP = File.join __dir__, '..', 'src', 'api_*.cpp'

# these functions we cannot port
NATIVE_ONLY = [
  'bool ImGui::DebugCheckVersionAndDataLayout(const char*, size_t, size_t, size_t, size_t, size_t, size_t)',
  'ImGuiContext* ImGui::CreateContext(ImFontAtlas*)',
  'ImGuiContext* ImGui::GetCurrentContext()',
  'void ImGui::SetCurrentContext(ImGuiContext*)',
  'void ImGui::DestroyContext(ImGuiContext*)',
  'ImGuiIO& ImGui::GetIO()',
  'ImGuiStyle& ImGui::GetStyle()',
  'void ImGui::NewFrame()',
  'void ImGui::EndFrame()',
  'void ImGui::Render()',
  'ImDrawData* ImGui::GetDrawData()',
  'ImDrawListSharedData* ImGui::GetDrawListSharedData()',
  'ImGuiViewport* ImGui::GetMainViewport()',
  'void ImGui::CaptureKeyboardFromApp(bool)',
  'void ImGui::CaptureMouseFromApp(bool)',

  'ImFont* ImGui::GetFont()',
  'void ImGui::PushFont(ImFont*)',
  'void ImGui::PopFont()',
  'void ImDrawList::AddText(const ImFont*, float, const ImVec2&, ImU32, const char*, const char*, float, const ImVec4*)',

  'void ImGui::ShowDemoWindow(bool*)',
  'void ImGui::ShowAboutWindow(bool*)',
  'void ImGui::ShowUserGuide()',
  'void ImGui::ShowStyleEditor(ImGuiStyle*)',
  'bool ImGui::ShowStyleSelector(const char*)',
  'void ImGui::ShowFontSelector(const char*)',
  'void ImGui::StyleColorsDark(ImGuiStyle*)',
  'void ImGui::StyleColorsLight(ImGuiStyle*)',
  'void ImGui::StyleColorsClassic(ImGuiStyle*)',

  'void ImGui::SetAllocatorFunctions(void* (*alloc_func)(size_t sz, void* user_data), void (*free_func)(void* ptr, void* user_data), void*)',
  'void* ImGui::MemAlloc(size_t)',
  'void ImGui::MemFree(void*)',

  'void ImGui::TextUnformatted(const char*, const char*)',
  'bool ImGui::CollapsingHeader(const char*, ImGuiTreeNodeFlags)',
  'bool ImGui::TreeNode(const char*)',
  'bool ImGui::TreeNode(const char*, const char*, ...)',

  'void ImDrawList::AddCallback(ImDrawCallback, void*)',
  'void ImDrawList::AddDrawCmd()',

  'void ImGui::SetStateStorage(ImGuiStorage*)',
  'ImGuiStorage* ImGui::GetStateStorage()',
  'void ImGui::LoadIniSettingsFromDisk(const char*)',
  'void ImGui::LoadIniSettingsFromMemory(const char*, size_t)',
  'void ImGui::SaveIniSettingsToDisk(const char*)',
  'const char* ImGui::SaveIniSettingsToMemory(size_t*)',

  'ImVec4 ImGui::ColorConvertU32ToFloat4(ImU32)',
  'ImU32 ImGui::ColorConvertFloat4ToU32(const ImVec4&)',
  'void ImGui::ColorConvertRGBtoHSV(float, float, float, float&, float&, float&)',

  # equivalent overload implemented as GetColorEx
  'ImU32 ImGui::GetColorU32(const ImVec4&)',

  # only const char* IDs
  'void ImGui::PushID(int)',
  'void ImGui::PushID(const void*)',
  'void ImGui::PushID(const char*, const char*)',
  'bool ImGui::BeginChild(ImGuiID, const ImVec2&, bool, ImGuiWindowFlags)',

  'ImGuiID ImGui::GetID(const char*)',
  'ImGuiID ImGui::GetID(const char*, const char*)',
  'ImGuiID ImGui::GetID(const void*)',

  'void ImGui::TreePush(const void*)',
  'bool ImGui::TreeNode(const void*, const char*, ...)',
  'bool ImGui::TreeNodeEx(const void*, ImGuiTreeNodeFlags, const char*, ...)',

  # item getter callback overloads
  'bool ImGui::Combo(const char*, int*, bool(*items_getter)(void* data, int idx, const char** out_text), void*, int, int)',
  'bool ImGui::ListBox(const char*, int*, bool (*items_getter)(void* data, int idx, const char** out_text), void*, int, int)',
  'void ImGui::PlotLines(const char*, float(*values_getter)(void* data, int idx), void*, int, int, const char*, float, float, ImVec2)',
  'void ImGui::PlotHistogram(const char*, float(*values_getter)(void* data, int idx), void*, int, int, const char*, float, float, ImVec2)',

  # float/ImVec2 overloads
  'void ImGui::PushStyleVar(ImGuiStyleVar, float)',

  # array + explicit size overload
  'bool ImGui::Combo(const char*, int*, const char* const, int, int)',

  # va_list overloads
  'bool ImGui::TreeNodeV(const char*, const char*, va_list)',
  'bool ImGui::TreeNodeV(const void*, const char*, va_list)',
  'bool ImGui::TreeNodeExV(const char*, ImGuiTreeNodeFlags, const char*, va_list)',
  'bool ImGui::TreeNodeExV(const void*, ImGuiTreeNodeFlags, const char*, va_list)',
  'void ImGui::SetTooltipV(const char*, va_list)',
  'void ImGui::TextV(const char*, va_list)',
  'void ImGui::TextColoredV(const ImVec4&, const char*, va_list)',
  'void ImGui::TextDisabledV(const char*, va_list)',
  'void ImGui::TextWrappedV(const char*, va_list)',
  'void ImGui::LabelTextV(const char*, const char*, va_list)',
  'void ImGui::BulletTextV(const char*, va_list)',

  # not recommended (use SetNextWindow* instead)
  'void ImGui::SetWindowPos(const ImVec2&, ImGuiCond)',
  'void ImGui::SetWindowSize(const ImVec2&, ImGuiCond)',
  'void ImGui::SetWindowCollapsed(bool, ImGuiCond)',
  'void ImGui::SetWindowFocus()',
  'void ImGui::SetWindowFontScale(float)', # old API

  # use the list clipper API instead
  'void ImGui::CalcListClipping(int, float, int*, int*)',

  # single-component scalar input
  'bool ImGui::DragScalar(const char*, ImGuiDataType, void*, float, const void*, const void*, const char*, ImGuiSliderFlags)',
  'bool ImGui::SliderScalar(const char*, ImGuiDataType, void*, const void*, const void*, const char*, ImGuiSliderFlags)',
  'bool ImGui::VSliderScalar(const char*, const ImVec2&, ImGuiDataType, void*, const void*, const void*, const char*, ImGuiSliderFlags)',
  'bool ImGui::InputScalar(const char*, ImGuiDataType, void*, const void*, const void*, const char*, ImGuiInputTextFlags)',

  # legacy Columns API (2020: prefer using Tables!)
  'void ImGui::Columns(int, const char*, bool)',
  'void ImGui::NextColumn()',
  'int ImGui::GetColumnIndex()',
  'float ImGui::GetColumnWidth(int)',
  'void ImGui::SetColumnWidth(int, float)',
  'float ImGui::GetColumnOffset(int)',
  'void ImGui::SetColumnOffset(int, float)',
  'int ImGui::GetColumnsCount()',

  # primitives allocation
  'void ImDrawList::PrimReserve(int, int)',
  'void ImDrawList::PrimUnreserve(int, int)',
  'void ImDrawList::PrimRect(const ImVec2&, const ImVec2&, ImU32)',
  'void ImDrawList::PrimRectUV(const ImVec2&, const ImVec2&, const ImVec2&, const ImVec2&, ImU32)',
  'void ImDrawList::PrimQuadUV(const ImVec2&, const ImVec2&, const ImVec2&, const ImVec2&, const ImVec2&, const ImVec2&, const ImVec2&, const ImVec2&, ImU32)',

  # images
  'ImVec2 ImGui::GetFontTexUvWhitePixel()',
  'void ImGui::Image(ImTextureID, const ImVec2&, const ImVec2&, const ImVec2&, const ImVec4&, const ImVec4&)',
  'bool ImGui::ImageButton(ImTextureID, const ImVec2&, const ImVec2&, const ImVec2&, int, const ImVec4&, const ImVec4&)',
  'void ImDrawList::PushTextureID(ImTextureID)',
  'void ImDrawList::PopTextureID()',
  'void ImDrawList::AddImage(ImTextureID, const ImVec2&, const ImVec2&, const ImVec2&, const ImVec2&, ImU32)',
  'void ImDrawList::AddImageQuad(ImTextureID, const ImVec2&, const ImVec2&, const ImVec2&, const ImVec2&, const ImVec2&, const ImVec2&, const ImVec2&, const ImVec2&, ImU32)',
  'void ImDrawList::AddImageRounded(ImTextureID, const ImVec2&, const ImVec2&, const ImVec2&, const ImVec2&, ImU32, float, ImDrawCornerFlags)',

  # value helpers
  'void ImGui::Value(const char*, bool)',
  'void ImGui::Value(const char*, int)',
  'void ImGui::Value(const char*, unsigned int)',
  'void ImGui::Value(const char*, float, const char*)',
]

NATIVE_ONLY_CLASSES = %w[
  ImGuiIO ImFontAtlas ImFont ImDrawData ImDrawListSplitter ImGuiStoragePair
  ImGuiStyle ImGuiInputTextCallbackData ImFontGlyphRangesBuilder
  ImGuiTextBuffer ImGuiTextFilter
]

NATIVE_ONLY_ENUMS = [
  /\AInputTextFlags_Callback/,
  /\ADataType_/,
  /\ANavInput_/,
  /\ABackendFlags_/,
  /\AFontAtlasFlags_/,
  'Cond_None',          # alias for Cond_Always
  /\AKey_.+/,           # for GetKeyIndex, not implemented
  /_NoSavedSettings\z/, # saved settings are not implemented yet
  'ColorEditFlags_HDR', # not allowed, would break float[4]<->int conversion
  /\AViewportFlags_/,
  'MouseCursor_None',   # not implemented under SWELL
  'TreeNodeFlags_NavLeftJumpsBackHere', # marked as WIP
  /\ATableFlags_NoBordersInBody/,       # marked as alpha, to be moved to style
  /\AConfigFlags_(NavEnableGamepad|NavNoCaptureKeyboard)\z/, # not implemented
  /\AConfigFlags_(IsSRGB|IsTouchScreen)\z/, # backend internal flags

  # only for dear imgui's internal use
  'InputTextFlags_Multiline',
  'InputTextFlags_NoMarkEdited',
  /\AWindowFlags_(NavFlattened|ChildWindow|Tooltip|Popup|Modal|ChildMenu)\z/,
  /\AColorEditFlags__.+Mask\z/,
  /\ADrawListFlags_/,
]

# these functions were ported using another name (eg. overloads)
RENAMES = {
  'bool ImGui::RadioButton(const char*, int*, int)'         => 'RadioButtonEx',
  'ImU32 ImGui::GetColorU32(ImGuiCol, float)'               => 'GetColor',
  'bool ImGui::TreeNodeEx(const char*, ImGuiTreeNodeFlags)' => 'TreeNode',
  'ImU32 ImGui::GetColorU32(ImU32)'                         => 'GetColorEx',
  'const ImVec4& ImGui::GetStyleColorVec4(ImGuiCol)'        => 'GetStyleColor',
  'bool ImGui::IsRectVisible(const ImVec2&, const ImVec2&)' => 'IsRectVisibleEx',
  'ImGuiTableSortSpecs* ImGui::TableGetSortSpecs()'         => 'TableGetColumnSortSpecs',

  # variable-component input only supports double
  'bool ImGui::DragScalarN(const char*, ImGuiDataType, void*, int, float, const void*, const void*, const char*, ImGuiSliderFlags)' => 'DragDoubleN',
  'bool ImGui::SliderScalarN(const char*, ImGuiDataType, void*, int, const void*, const void*, const char*, ImGuiSliderFlags)'      => 'SliderDoubleN',
  'bool ImGui::InputScalarN(const char*, ImGuiDataType, void*, int, const void*, const void*, const char*, ImGuiInputTextFlags)'    => 'InputDoubleN',
}

ARG_RENAMES = {
  'IsKeyDown'     => { 'user_key_index' => 'key_code' },
  'IsKeyPressed'  => { 'user_key_index' => 'key_code' },
  'IsKeyReleased' => { 'user_key_index' => 'key_code' },
}

# these functions were not ported 1:1 (same name, otherwise add to RENAMES above too!)
OVERRIDES = {
  'const char* ImGui::GetVersion()' => 'void GetVersion(char*, int, char*, int)',
  'void ImGui::ColorConvertHSVtoRGB(float, float, float, float&, float&, float&)' => 'int ColorConvertHSVtoRGB(double, double, double, double*)',
  'void ImGui::PushStyleVar(ImGuiStyleVar, const ImVec2&)'                        => 'void PushStyleVar(int, double, double*)',
  'bool ImGui::SetDragDropPayload(const char*, const void*, size_t, ImGuiCond)'   => 'bool SetDragDropPayload(const char*, const char*, int*)',
  'const ImGuiPayload* ImGui::GetDragDropPayload()'                               => 'bool GetDragDropPayload(char*, int, char*, int, bool*, bool*)',
  'bool ImGui::TreeNodeEx(const char*, ImGuiTreeNodeFlags, const char*, ...)'     => 'bool TreeNodeEx(const char*, const char*, int*)',
  'ImGuiTableSortSpecs* ImGui::TableGetSortSpecs()'                               => 'bool TableGetColumnSortSpecs(int, int*, int*, int*, int*)',

  # color array -> packed int
  'bool ImGui::ColorPicker4(const char*, float[4], ImGuiColorEditFlags, const float*)' => 'bool ColorPicker4(const char*, int*, int*, int*)',
  'const ImVec4& ImGui::GetStyleColorVec4(ImGuiCol)' => 'int GetStyleColor(int)',

  # (array, array_size) -> reaper_array*
  'void ImGui::PlotLines(const char*, const float*, int, int, const char*, float, float, ImVec2, int)'     => 'void PlotLines(const char*, reaper_array*, int*, const char*, double*, double*, double*, double*)',
  'void ImGui::PlotHistogram(const char*, const float*, int, int, const char*, float, float, ImVec2, int)' => 'void PlotHistogram(const char*, reaper_array*, int*, const char*, double*, double*, double*, double*)',
  'void ImDrawList::AddPolyline(const ImVec2*, int, ImU32, bool, float)' => 'void DrawList_AddPolyline(reaper_array*, int, bool, double)',
  'void ImDrawList::AddConvexPolyFilled(const ImVec2*, int, ImU32)'      => 'void DrawList_AddConvexPolyFilled(reaper_array*, int, int)',

  # no callbacks
  'bool ImGui::InputText(const char*, char*, size_t, ImGuiInputTextFlags, ImGuiInputTextCallback, void*)'                         => 'bool InputText(const char*, char*, int, int*)',
  'bool ImGui::InputTextMultiline(const char*, char*, size_t, const ImVec2&, ImGuiInputTextFlags, ImGuiInputTextCallback, void*)' => 'bool InputTextMultiline(const char*, char*, int, double*, double*, int*)',
  'bool ImGui::InputTextWithHint(const char*, const char*, char*, size_t, ImGuiInputTextFlags, ImGuiInputTextCallback, void*)'    => 'bool InputTextWithHint(const char*, const char*, char*, int, int*)',
  'void ImGui::SetNextWindowSizeConstraints(const ImVec2&, const ImVec2&, ImGuiSizeCallback, void*)' => 'void SetNextWindowSizeConstraints(double, double, double, double)',

  # const char* (null-terminated) -> char* (\31-terminated)
  'bool ImGui::Combo(const char*, int*, const char*, int)' => 'bool Combo(const char*, int*, char*, int*)',

  # const char*[] + int size -> char* (\31-terminated)
  'bool ImGui::ListBox(const char*, int*, const char* const, int, int)' => 'bool ListBox(const char*, int*, char*, int*)',

  # no text_end argument
  'ImVec2 ImGui::CalcTextSize(const char*, const char*, bool, float)'        => 'void CalcTextSize(const char*, double*, double*, bool*, double*)',
  'void ImDrawList::AddText(const ImVec2&, ImU32, const char*, const char*)' => 'void DrawList_AddText(double, double, int, const char*)',

  'bool ImGui::DragScalarN(const char*, ImGuiDataType, void*, int, float, const void*, const void*, const char*, ImGuiSliderFlags)' => 'bool DragDoubleN(const char*, reaper_array*, double*, double*, double*, const char*, int*)',
  'bool ImGui::SliderScalarN(const char*, ImGuiDataType, void*, int, const void*, const void*, const char*, ImGuiSliderFlags)'      => 'bool SliderDoubleN(const char*, reaper_array*, double, double, const char*, int*)',
  'bool ImGui::InputScalarN(const char*, ImGuiDataType, void*, int, const void*, const void*, const char*, ImGuiInputTextFlags)'    => 'bool InputDoubleN(const char*, reaper_array*, double*, double*, const char*, int*)',

  # drag/drop payload as string
  'const ImGuiPayload* ImGui::AcceptDragDropPayload(const char*, ImGuiDragDropFlags)' => 'bool AcceptDragDropPayload(const char*, char*, int, int*)',
}

# argument position & name are checked
RESOURCES = {
  'ImGui_Context*'     => 'ctx',
  'ImGui_DrawList*'    => 'draw_list',
  'ImGui_ListClipper*' => 'clipper',
}

# types REAPER's parser knows about
TYPES = [
  'bool',   'bool*',
  'int',    'int*',    # no unsigned int :-(
  'double', 'double*', # no float :'(
  'ImGui_Context*',
  'ImGui_DrawList*',
  'ImGui_ListClipper*',
  'char*',
  'const char*',
  'reaper_array*',
  'void*',
]

class Function < Struct.new :type, :name, :args, :namespace, :match
  def sig
    return @sig if @sig
    arg_types = args.map {|arg|
      next arg unless arg.is_a? Argument
      if arg.size > 0
        "#{arg.type}[#{arg.size}]"
      else
        arg.type
      end
    }
    ns = namespace ? "#{namespace}::" : ''
    @sig = "#{type} #{ns}#{name}(#{arg_types.join ', '})".freeze
  end

  def normalized
    return @normalized if @normalized

    ns = case namespace
         when 'ImGui'
           nil
         when /\AIm(?:Gui)?/
           namespace[$~[0].size..-1]
         end

    normal = self.class.new
    normal.type = cpp_type_to_reascript_type type
    normal.namespace = nil
    normal.name = RENAMES[sig] || (ns ? "#{ns}_#{name}" : name)
    normal.name.gsub! /Float(?=\b|\d)/, 'Double'
    normal.args = args.dup
    normal.args = args.flat_map do |arg|
      cpp_arg_to_reascript_args arg
    end

    if normal.args.last == '...'
      fmt = normal.args.find { _1.name == 'fmt' }
      fmt.name = 'text'
      normal.args.pop
    end

    if normal.type == 'ImVec2'
      x = Argument.new 'double*', nil, nil, 0
      y = x.dup
      if normal.name =~ /Size/
        x.name = 'w'
        y.name = 'h'
      else
        x.name = 'x'
        y.name = 'y'
      end

      normal.type = 'void'
      pos = normal.args.index { not _1.default.nil? }
      pos ||= normal.args.size
      normal.args.insert pos, x
      normal.args.insert pos+1, y
    end

    @normalized = normal
  end

private
  def cpp_type_to_reascript_type(type)
    case type
    when /float(\*)?/
      "double#{$~[1]}"
    when /unsigned int(\*)?/, /size_t(\*)?/
      "int#{$~[1]}"
    when 'ImDrawList*'
      'ImGui_DrawList*'
    when /\AIm(?:Gui|Draw)[^\*]+(?:Flags\*)?\z/, 'ImU32'
      'int'
    when 'const char* const'
      'const char*'
    else
      type
    end
  end

  def cpp_arg_to_reascript_args(arg)
    return arg unless arg.is_a? Argument

    out = [arg]

    if arg.default == 'NULL'
      arg.default = 'nil'
    elsif arg.default == '0' && arg.type.start_with?('ImGui')
      arg.default = arg.type + '_None'
      arg.default.insert 5, '_'
      arg.default = 'ImGui_Cond_Always' if arg.default == 'ImGui_Cond_None'
      arg.default = 'ImGui_MouseButton_Left' if arg.default == 'ImGui_MouseButton_None'
    elsif arg.default =~ /\AIm(Gui)?[\w_]+\z/
      arg.default.gsub! /\AIm(Gui)?/, 'ImGui_'
    elsif arg.default == '1' && arg.type == 'ImGuiPopupFlags'
      arg.default = 'ImGui_PopupFlags_MouseButtonRight'
    elsif !arg.default.nil? && arg.type == 'float'
      arg.default = arg.default[0..-2] # 0.0f -> 0.0
    elsif arg.default =~ /\A"(.+)"\z/
      arg.default = "'#{$~[1]}'"
    end

    arg.name += '_rgba' if arg.type == 'ImU32' && %[col color].include?(arg.name)

    arg.type = cpp_type_to_reascript_type arg.type

    if arg.type.include? 'ImVec2'
      arg.type = 'double'
      arg.type += '*' if arg.default
      out << Argument.new(arg.type, arg.name, arg.default, arg.size)

      if arg.name =~ /size/
        out.first.name += '_w'
        out.last.name  += '_h'
      else
        out.first.name += '_x'
        out.last.name  += '_y'
      end

      if arg.default =~ /ImVec2\((.+?)f?,\s*(.+?)f?\)/
        out.first.default = $~[1]
        out.last.default  = $~[2]

        out.first.default = '0.0' if out.first.default == '0'
        out.last.default  = '0.0' if out.last.default  == '0'
      end
    elsif arg.type.include?('ImVec4') && arg.name.include?('col')
      arg.type = 'int'
      arg.name += '_rgba'
    elsif arg.type == 'double' && arg.name == 'col' && arg.size.between?(3, 4)
      arg.type = 'int*'
      arg.name += '_rgb'
      arg.name += 'a' if arg.size == 4
      arg.size = 0
    end

    arg.type += '*' if arg.default && arg.type[-1] != '*'

    if arg.size > 1
      out = []
      arg.size.times do |n|
        array_el = arg.dup
        array_el.type += '*' # C arrays are pointers
        array_el.name = array_el.name + (n + 1).to_s
        array_el.size = 0
        out << array_el
      end
      return out
    end

    out
  end
end

Argument = Struct.new :type, :name, :default, :size

# load ImGui definitions
IMGUI_FUNC_R  = /IMGUI_API \s+ (?<type>[\w\*\&\s]+?) \s+ (?<name>[\w]+) \( (?<args>.*?) \) (?:\s*IM_[A-Z]+\(.+\))?; /x
IMGUI_ARG_R   = /\A(?<type>[\w\*&\s\<\>]+) \s+ (?<name>\w+) (?:\[ (?<size>\d*) \])? (?:\s*=\s*(?<default>.+))?\z/x
IMGUI_ENUM_R  = /\A\s* Im(?:Gui)?(?<name>[\w_]+) \s* (?:,|=)/x
IMGUI_CLASS_R = /(?:namespace|struct) (?<name>\w+)/

def split_imgui_args(args)
  args.split(/,\s*(?=[^\)]*(?:\(|$)) /).map do |arg|
    next arg unless arg =~ IMGUI_ARG_R
    Argument.new $~[:type], $~[:name], $~[:default], $~[:size].to_i
  end
end

imgui_funcs, imgui_enums = [], []
namespace = '', in_obsolete = false
File.foreach IMGUI_H do |line|
  if in_obsolete
    in_obsolete = false if line.chomp == '#endif'
    next
  end

  if line =~ IMGUI_FUNC_R
    args = split_imgui_args $~[:args]
    imgui_funcs << Function.new($~[:type], $~[:name], args, namespace)
  elsif line =~ IMGUI_ENUM_R
    next if $~[:name].end_with? '_COUNT'
    next if $~[:name].end_with? '_'
    imgui_enums << $~[:name]
  elsif line.chomp == '#ifndef IMGUI_DISABLE_OBSOLETE_FUNCTIONS'
    in_obsolete = true
  elsif line =~ IMGUI_CLASS_R
    namespace = $~[:name]
  end
end

puts "imgui:    found %d functions, %d enums (total: %d symbols)" %
  [imgui_funcs.size, imgui_enums.size, imgui_funcs.size + imgui_enums.size]

# load ReaImGui definitions
REAIMGUI_FUNC_R = /\ADEFINE_API \s*\(\s* (?<type>[\w\s\*]+) \s*,\s* (?<name>[\w]+) \s*,\s* (?<args>.*?) \s*(?<arg_end>,)?\s*(\/|\Z)/x
REAIMGUI_ENUM_R = /\ADEFINE_ENUM \s*\(\s* (?<prefix>\w+) \s*,\s* (?<name>\w+) \s*,\s*/x
REAIMGUI_ARGS_R = /\A\s* (?<args>\(.+?\)) \s*(?<arg_end>,)?\s*(\/|\Z)/x
REAIMGUI_DEFS_R = /\A"?Default values: (?<values>.+?)(?:\.?(?:\).?)?",)?\Z/
REAIMGUI_DEF_R  = /\A(?<name>[\w_]+) = (?<value>.+)/
REAIMGUI_ARGN_R =  /\A(?:(?<raw_name>[^\(\)]+)|(?<decoration>[^\(]+)\((?<raw_name>[^\)]+)\))\z/

def split_reaimgui_args(args)
  args = args.split ')('
  return args if args.size < 1

  args.first[0] = '' # remove leading (
  args.last[-1] = '' # remove trailing )

  args.map do |arg|
    type, name = arg.split /\s*,\s*/
    Argument.new type, name, nil, 0
  end
end

def add_reaimgui_defaults(func, values)
  values = values.split ', ' # strict with whitespace
  values.each do |value|
    if not value =~ REAIMGUI_DEF_R
      warn "#{func.name}: invalid default value: #{value}"
      next
    end

    name, default = $~[:name], $~[:value]

    arg = func.args.find {
      _1.name =~ REAIMGUI_ARGN_R
      $~[:raw_name] == name && $~[:decoration]&.[](-1) == 'O'
    }

    if not arg then
      warn "#{func.name}: default for unknown optional argument: #{value}"
      next
    end

    arg.default = default
  end
end

reaimgui_funcs, reaimgui_enums = [], []
Dir.glob(REAIMGUI_API_CPP).each do |source_file|
  in_function, want_args = false, false
  File.foreach source_file do |line|
    if line =~ REAIMGUI_FUNC_R
      in_function = true
      args = split_reaimgui_args $~[:args]
      func = Function.new $~[:type], $~[:name], args
      reaimgui_funcs << func
      want_args = !$~[:arg_end]
    elsif line =~ REAIMGUI_ENUM_R
      reaimgui_enums << $~[:name]
    elsif line.chomp == '});'
      in_function = false
    elsif in_function
      # parse subsequent lines inside a function definition
      if line.include? '{'
        want_args = false
      elsif want_args && line =~ REAIMGUI_ARGS_R
        reaimgui_funcs.last.args += split_reaimgui_args $~[:args]
        want_args = !$~[:arg_end]
      elsif line =~ REAIMGUI_DEFS_R
        add_reaimgui_defaults reaimgui_funcs.last, $~[:values]
      end
    end
  end
end

puts "reaimgui: found %d functions, %d enums (total: %d symbols)" %
  [reaimgui_funcs.size, reaimgui_enums.size, reaimgui_funcs.size + reaimgui_enums.size]

# basic argument type validation
reaimgui_funcs.each do |func|
  unless func.type == 'void' || TYPES.include?(func.type)
    warn "#{func.name}: invalid return type: #{func.type}"
  end

  func.args.each_with_index do |arg, i|
    unless TYPES.include? arg.type
      warn "#{func.name}: invalid argument type for '#{arg.name}': #{arg.type}"
    end

    if RESOURCES.has_key?(arg.type)
      unless i == 0
        warn "#{func.name}: argument of type '#{arg.type}' should come first"
      end

      unless arg.name == RESOURCES[arg.type]
        warn "#{func.name}: argument of type '#{arg.type}' should be named '#{RESOURCES[arg.type]}', got '#{arg.name}'"
      end
    end
  end

  # ignore leading resource type for easier matching
  func.args.shift if RESOURCES.has_key? func.args.first.type
end

NATIVE_ONLY.each do |sig|
  unless imgui_funcs.any? { _1.sig == sig }
    warn "function marked as native only not found in dear imgui: #{sig}"
  end
end

NATIVE_ONLY_ENUMS.each do |rule|
  reaimgui_enums.select { _1.match? rule }.each do |enum|
    warn "enum marked as native only but exported anyway: #{enum}"
  end
end
# link dear imgui functions to their corresponding ReaImGui counterparts
perfect_count = manual_count = missing_overloads = missing_count = skipped_count = 0
imgui_funcs.each do |imgui_func|
  if imgui_func.name[0] == '_' ||
      NATIVE_ONLY.include?(imgui_func.sig) ||
      NATIVE_ONLY_CLASSES.include?(imgui_func.namespace)
    skipped_count += 1
    next
  end

  candidate = reaimgui_funcs.find { imgui_func.normalized.name == _1.name }
  expected_sig = OVERRIDES[imgui_func.sig] || imgui_func.normalized.sig

  if not candidate
    missing_count += 1
    warn "not implemented: #{imgui_func.sig}"
    warn "  expected:  #{expected_sig}"
    next
  end

  perfect_match = candidate.sig == expected_sig

  if perfect_match
    if OVERRIDES.has_key? imgui_func.sig
      manual_count += 1
    else
      perfect_count += 1
      candidate.match = imgui_func
    end
  else
    missing_overloads += 1

    warn "not implemented: #{imgui_func.sig}"
    warn "  expected:  #{expected_sig}"
    warn "  candidate: #{candidate.sig}"
  end
end

# check argument names and default values
reaimgui_funcs.each do |func|
  func.args.each_with_index do |rea_arg, i|
    unless rea_arg.name =~ REAIMGUI_ARGN_R
      warn "#{func.name}: invalid argument ##{i+1} '#{rea_arg.name}'"
      next
    end

    raw_name, decoration = $~[:raw_name], $~[:decoration]

    unless raw_name =~ /\A[a-z0-9_]+\z/
      warn "#{func.name}: invalid argument ##{i+1} name '#{raw_name}' (not snake case?)"
      next
    end

    unless func.match
      if decoration && decoration[-1] == 'O' && rea_arg.default.nil?
        warn "#{func.name}: argument ##{i+1} '#{raw_name}' has no documented default value"
      end
      next
    end

    imgui_arg = func.match.normalized.args[i]

    unless raw_name == imgui_arg.name || raw_name == ARG_RENAMES[func.name]&.[](imgui_arg.name)
      warn "#{func.name}: argument ##{i+1} of type '#{rea_arg.type}' (#{decoration}) is named '#{raw_name}', expected '#{imgui_arg.name}'"
    end

    unless rea_arg.default == imgui_arg.default
      if rea_arg.default.nil?
        warn "#{func.name}: argument ##{i+1} '#{raw_name}' has no documented default value, expected #{imgui_arg.default}"
      else
        warn "#{func.name}: argument ##{i+1} '#{raw_name}' has documented default value #{rea_arg.default}, expected #{imgui_arg.default}"
      end
    end
  end
end

skipped_enums = 0
imgui_enums.each do |im_enum|
  unless reaimgui_enums.include? im_enum
    if NATIVE_ONLY_ENUMS.any? { im_enum.match? _1 }
      skipped_enums += 1
      next
    end

    warn "missing enum: #{im_enum}"
  end
end

puts
puts "functions: %d perfect matches, %d manual matches, %d missing overloads, %d not implemented, %d skipped" %
  [perfect_count, manual_count, missing_overloads, missing_count, skipped_count]

puts "functions: %.2f%% complete (%.2f%% total)" %
  [(perfect_count + manual_count).to_f / (imgui_funcs.size - skipped_count) * 100,
   (perfect_count + manual_count).to_f / imgui_funcs.size * 100]

puts "enums:     %d skipped" % skipped_enums
puts "enums:     %.2f%% complete (%.2f%% total)" %
  [reaimgui_enums.size.to_f / (imgui_enums.size - skipped_enums) * 100,
   reaimgui_enums.size.to_f / imgui_enums.size * 100]
