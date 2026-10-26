# Copyright © 2011-2022 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

# Be sure to restart your server when you modify this file

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# Add additional assets to the load path
Rails.application.config.assets.paths << Rails.root.join("node_modules")

# Missing fonts: font-awesome (SPARCRequest nav bar) and bootstrap glyphicons (Catalog Manager)
# on the server, so we need to precompile them.
# config/initializers/assets.rb
Rails.application.config.assets.precompile += %w[
  font-awesome/fa-solid-900.woff2
  font-awesome/fa-solid-900.woff
  font-awesome/fa-solid-900.ttf
  font-awesome/fa-brands-400.woff2
  font-awesome/fa-brands-400.woff
  font-awesome/fa-brands-400.ttf
  font-awesome/fa-regular-400.woff2
  font-awesome/fa-regular-400.woff
  font-awesome/fa-regular-400.ttf
  -# missing bootstrap glyphicons fonts (in )Catalog Manager) on the server
  bootstrap/glyphicons-halflings-regular.woff2
  bootstrap/glyphicons-halflings-regular.woff
  bootstrap/glyphicons-halflings-regular.ttf
  bootstrap/glyphicons-halflings-regular.eot
  bootstrap/glyphicons-halflings-regular.svg
]
