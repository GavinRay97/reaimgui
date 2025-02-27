/* ReaImGui: ReaScript binding for Dear ImGui
 * Copyright (C) 2021  Christian Fillion
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef REAIMGUI_RESOURCE_HPP
#define REAIMGUI_RESOURCE_HPP

#include <memory>

class Resource {
public:
  Resource();
  Resource(const Resource &) = delete;
  virtual ~Resource();

  template<typename T>
  static bool exists(T *userData)
  {
    static_assert(!std::is_same_v<Resource, T>);

    // static_cast needed for dynamic_cast to check whether it's really a T
    Resource *resource { static_cast<Resource *>(userData) };
    return exists(resource) && dynamic_cast<T *>(resource);
  }

protected:
  virtual void heartbeat() = 0;

private:
  class Timer;
  std::shared_ptr<Timer> m_timer;
};

template<>
bool Resource::exists<Resource>(Resource *);

#endif
