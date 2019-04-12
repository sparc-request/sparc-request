// Copyright © 2011-2019 MUSC Foundation for Research Development~
// All rights reserved.~

// Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

// 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

// 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
// disclaimer in the documentation and/or other materials provided with the distribution.~

// 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
// derived from this software without specific prior written permission.~

// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
// BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
// SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
// TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

$(document).ready( function() {
  var determineBatchSelectedClass = function(type) {
    switch(type) {
      case 'success':
        return 'btn btn-success';
      case 'warning':
        return 'btn btn-danger';
      default:
        return 'btn btn-primary';
    }
  };

  var determineHighlightClass = function(type) {
    switch(type) {
      case 'success':
        return 'success';
      case 'warning':
        return 'danger';
      default:
        return 'primary';
    }
  };

  var determineSwalConfirmColor = function(type) {
    // Colors pulled from assets/stylesheets/proper/colors.sass
    switch(type) {
      case 'success':
        return '#2C9A4D'
      case 'warning':
        return '#C43149'
      default:
        return '#227BA4';
    }
  };

  var BatchSelect = function (els, options) {
    this.options = options;
    this.$els = $(els).filter(':not(.disabled, [disabled=disabled])');
    this.$checks = $();
    this.$container = this.$els.parents('tbody');

    this.init();
  };

  BatchSelect.DEFAULTS = {
    ajaxType: 'get',
    ajaxDataType: 'script',
    ajaxUrl: '/',
    ajaxData: {},
    batchSelectedClass: null,
    batchSelectedText: 'Submit Selected',
    checkConfirmSwalTitle: 'Are you sure?',
    checkConfirmSwalText: 'You cannot undo this action.',
    highlightClass: null,
    swalTitleSingle: 'Are you sure?',
    swalTextSingle: 'You cannot undo this action.',
    swalConfirmColor: null,
    type: 'success'
  };

  BatchSelect.prototype.init = function () {
    var that = this;

    $.each(that.$els, function (i, el) {
      that.initGroup(el);
    });
  };

  BatchSelect.prototype.initGroup = function (el) {
    var that = this,
        $el = $(el),
        id = $el.data('id'),
        group = {
          $el:     $el,
          $check:  ($check = $("<input class=\"batch-select-check\" type=\"checkbox\" value=\"" + id + "\" data-id=\"" + id + "\" style=\"width:100%;height:31px;\" />")),
          $tr:     ($tr = $el.closest('tr'))
        };

    this.$checks = this.$checks.add($check);

    $check.hide();
    $el.after($check);

    var mouseDownTimeout = null;

    $el.on('mousedown', function () {
      var $el = $(this),
          $check = $el.siblings('.batch-select-check');

      mouseDownTimeout = setInterval( function() {
        that.toggleGroups(true);

        if ($el.data('batch-select') && $el.data('batch-select').checkConfirm) {
          that.checkConfirmSwal($check);
          that.showBatchSelected($el);
        } else {
          that.toggleCheckbox($check);
          that.showBatchSelected($el);
        }
        clearTimeout(mouseDownTimeout);
      }, 500);
    });

    $el.on('mouseup', function () {
      clearTimeout(mouseDownTimeout);
    });

    $el.on('click', function () {
      var $el = $(this);

      swal({
        title: that.options.swalTitle,
        text: that.options.swalText,
        type: that.options.type,
        showCancelButton: true,
        confirmButtonColor: that.options.swalConfirmColor || determineSwalConfirmColor(that.options.type)
      }, function () {
        that.sendRequest($el.data('id'));
      });
    });

    $check.on('click', function(event) {
      var $check = $(this),
          $el = $check.siblings();

      // Cancel out the click event
      $check.prop('checked', !$check.prop('checked'));

      if ($el.data('batch-select') && $el.data('batch-select').checkConfirm) {
        that.checkConfirmSwal($check);
      } else {
        that.toggleCheckbox($check);
      }
    });
  };

  BatchSelect.prototype.showBatchSelected = function ($el) {
    var that = this,
        $tr = $el.parents('tr'),
        position = $tr.position();

    if (position) {
      this.$selectedButtonContainer1  = $("<div style=\"position:absolute;\"></div>")
      this.$selectedButtonContainer2  = $("<div style=\"position:relative;height:100%;\"></div>");
      this.$selectedButtonContainer3  = $("<div style=\"position:absolute;\"></div>");
      this.$selectedButton            = $("<button class=\"" + (this.options.batchSelectedClass || determineBatchSelectedClass(this.options.type)) + " batch-selected-btn\" style=\"position:sticky;top:15px;bottom:15px;\">" + this.options.batchSelectedText + "</button>");

      this.$selectedButtonContainer1.append(this.$selectedButtonContainer2)
      this.$selectedButtonContainer2.append(this.$selectedButtonContainer3)
      this.$selectedButtonContainer3.append(this.$selectedButton)
      this.$container.append(this.$selectedButtonContainer1);

      var trPadd  = ($tr.outerHeight() - this.$selectedButton.outerHeight()) / 2,
          height  = this.$container.outerHeight() - (trPadd * 2),
          width   = this.$selectedButton.outerWidth(),
          top1    = this.$container.siblings('thead').outerHeight() + trPadd,
          top3    = position.top + trPadd - top1;

      this.$selectedButtonContainer1.css('height', height + "px");
      this.$selectedButtonContainer3.css('height', height - top3 + "px");
      this.$selectedButtonContainer1.css('width', width + "px");
      this.$selectedButtonContainer2.css('width', width + "px");
      this.$selectedButtonContainer1.css('right', -(width + 30) + "px");
      this.$selectedButtonContainer1.css('top', top1 + "px");
      this.$selectedButtonContainer3.css('top', top3 + "px");

      this.$selectedButton.on('click', function () {
        swal({
          title: that.options.swalTitle,
          text: that.options.swalText,
          type: that.options.type,
          showCancelButton: true,
          confirmButtonColor: that.options.swalConfirmColor || determineSwalConfirmColor(that.options.type)
        }, function () {
          var ids = $.map(that.$checks, function(el, i) {
            return $(el).prop('checked') ? $(el).data('id') : '';
          }).join(',');

          that.sendRequest(ids);
        });
      });
    }
  };

  BatchSelect.prototype.hideBatchSelected = function() {
    this.$selectedButton.remove();
  }

  BatchSelect.prototype.toggleGroups = function(showChecks) {
    $.each(this.$els, function (i, el) {
      var $el = $(el),
          $check = $el.siblings('.batch-select-check');

      if (showChecks) {
        $el.hide();
        $check.show();
      } else {
        $el.show();
        $check.hide();
      }
    });
  };

  BatchSelect.prototype.checkConfirmSwal = function($check) {
    var that = this;

    swal({
      title: that.options.checkConfirmSwalTitle,
      text: that.options.checkConfirmSwalText,
      type: that.options.type,
      showCancelButton: true,
      confirmButtonColor: that.options.swalConfirmColor || determineSwalConfirmColor(that.options.type)
    }, function () {
      that.toggleCheckbox($check);
    });
  };

  BatchSelect.prototype.toggleCheckbox = function($check) {
    var $tr = $check.parents('tr'),
        checked = $check.is(':checked'),
        klass = this.options.highlightClass || determineHighlightClass(this.options.type);

    $check.prop('checked', !checked);
    checked ? $tr.removeClass(klass) : $tr.addClass(klass);

    if (this.$checks.filter(':checked').length === 0) {
      this.toggleGroups(false);
      this.hideBatchSelected();
    }
  };

  BatchSelect.prototype.sendRequest = function(id) {
    $.ajax({
      type: this.options.ajaxType,
      dataType: this.options.ajaxDataType,
      url: this.options.ajaxUrl + id,
      data: this.options.ajaxData
    });
  }

  $.fn.batchSelect = function (option) {
    var $this = $(this),
        data = $this.data('batch.select'),
        options = $.extend({}, BatchSelect.DEFAULTS, $this.data('batch-select'), typeof option === 'object' && option);

    if (!data) {
      $this.data('batch.select', (data = new BatchSelect(this, options)));
    }

    return this;
  };
});
