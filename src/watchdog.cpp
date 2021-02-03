#include "watchdog.hpp"

#include "window.hpp"

#include <reaper_plugin_functions.h>

static std::weak_ptr<Watchdog> g_instance;

std::shared_ptr<Watchdog> Watchdog::get()
{
  if(!g_instance.expired())
    return g_instance.lock();

  auto instance { std::make_shared<Watchdog>() };
  g_instance = instance;
  return instance;
}

Watchdog::Watchdog()
{
  plugin_register("timer", reinterpret_cast<void *>(&timerTick));
}

Watchdog::~Watchdog()
{
  plugin_register("-timer", reinterpret_cast<void *>(&timerTick));
}

void Watchdog::timerTick()
{
  Window::heartbeat();
}
