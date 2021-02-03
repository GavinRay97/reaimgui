#ifndef REAIMGUI_WINDOW_HPP
#define REAIMGUI_WINDOW_HPP

#include <memory>
#include <reaper_plugin.h>
#include <tuple>
#include <WDL/wdltypes.h>

class Watchdog;
struct ImDrawData;
struct ImFontAtlas;
struct ImGuiContext;

class Window {
public:
  static REAPER_PLUGIN_HINSTANCE s_instance;
  static bool exists(Window *);
  static size_t count();
  static void heartbeat();

  Window(const char *title, int x, int y, int w, int h);
  Window(const Window &) = delete;
  ~Window();

  HWND handle() const { return m_handle; }
  bool isCloseRequested() const { return m_closeReq; }
  unsigned int clearColor() const;
  void setClearColor(unsigned int rgba);

  void enterFrame();
  void endFrame(bool render);
  void close();

private:
  static WDL_DLGRET proc(HWND, UINT, WPARAM, LPARAM);
  struct PlatformDetails;

  void setupContext();
  void platformInit();
  void platformBeginFrame();
  void platformEndFrame(ImDrawData *);
  void platformTeardown();

  HWND m_handle;
  bool m_keepAlive, m_inFrame, m_closeReq;
  std::tuple<float, float, float, float> m_clearColor;

  ImGuiContext *m_ctx;
  PlatformDetails *m_p;
  std::shared_ptr<Watchdog> m_watchdog;
  std::shared_ptr<ImFontAtlas> m_fontAtlas;
};

#endif
