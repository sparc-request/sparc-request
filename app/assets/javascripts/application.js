// Copyright © 2011-2019 MUSC Foundation for Research Development
// All rights reserved.

// Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

// 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

// 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
// disclaimer in the documentation and/or other materials provided with the distribution.

// 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
// derived from this software without specific prior written permission.

// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
// BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
// SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
// TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

//////////////////////
/// IE11 Polyfills ///
//////////////////////

// Polyfill for position: sticky
//= require stickybits/dist/stickybits.min

// Polyfill for ES6 Promise
//= require promise-polyfill/dist/polyfill.min

// Polyfill for URL
//= require url-polyfill/url-polyfill.min


///////////////////////////////////////
/// These need to be required first ///
///////////////////////////////////////

//= require i18n/translations
//= require sweetalert2/dist/sweetalert2.min
//= require custom/sweetalert-custom
//= require custom/sweetalert-integration
//= require jquery/dist/jquery.min
//= require rails-ujs

//////////////////////////////////
/// Require Remaining Packages ///
//////////////////////////////////

//= require popper.js/dist/umd/popper.min
//= require bootstrap/dist/js/bootstrap.min
//= require bootstrap-select/dist/js/bootstrap-select.min
//= require bootstrap-table/dist/bootstrap-table.min
//= require bootstrap-table/dist/extensions/export/bootstrap-table-export.min
//= require bootstrap4-toggle/js/bootstrap4-toggle
//= require corejs-typeahead/dist/typeahead.bundle.min
//= require moment/min/moment-with-locales.min
//= require tempusdominus-bootstrap-4/build/js/tempusdominus-bootstrap-4
//= require js-cookie/src/js.cookie
//= require nprogress/nprogress

//////////////////////////////////
/// Require Our Custom Scripts ///
//////////////////////////////////

//= require custom/bootstrap-custom
//= require custom/bootstrap-select-custom
//= require custom/tempusdominus-custom
//= require custom/nprogress-custom

///////////////////////////
/// Require Our Scripts ///
///////////////////////////

/// Replace with //= require_tree . when finished! ///

//= require utilities
//= require global
//= require batch-select
//= require identities
//= require service_requests
//= require protocols
//= require protocol_form
//= require associated_users
//= require associated_users_form
//= require subsidies
//= require documents
//= require review
//= require confirmation

//= require service_calendar

//= require dashboard/protocols
//= require dashboard/notifications
//= require dashboard/epic_queues
//= require dashboard/sub_service_requests
//= require funding/documents

//= require reporting

//= require surveyor/responses
//= require surveyor/surveys
