  $(document).ready(function() {

    $('#not_called').DataTable({
      scrollY: "65vh",
      scrollCollapse: true,
      paging: false,
      autoWidth: true,
      responsive: true,
      retrieve: true,
      info: false,
      searching: false,
    });

    $('#not_ordered').DataTable({
      scrollY: "65vh",
      scrollCollapse: true,
      paging: false,
      autoWidth: true,
      responsive: true,
      retrieve: true,
      info: false,
      searching: false,
    });

    $('#normal_dt').DataTable({
      scrollY: "60vh",
      scrollCollapse: true,
      paging: false,
      autoWidth: true,
      responsive: true,
      retrieve: true,
      info: false,
      searching: false,
      columnDefs: [ {
          targets: [ 0 ],
          orderData: [ 0, 1 ]
      }, {
          targets: [ 1 ],
          orderData: [ 1, 0 ]
      }, {
          targets: [ 4 ],
          orderData: [ 4, 0 ]
      } ],
    });

    $('#listtab').DataTable({
      scrollY: "60vh",
      scrollCollapse: true,
      paging: false,
      autoWidth: true,
      responsive: true,
      retrieve: true,
      info: false,
      searching: false,
    });

    $("#btnPrint").printPreview({
      obj2print:'#main'
    });

  });
