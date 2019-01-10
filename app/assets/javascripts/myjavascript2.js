  function getData(data) {
    var p1 = data.replace('[', "");
    var p2 = p1.replace(']', "");
    p1 = p2.replace(/"/g, "");
    p2 = p1.replace(/,/g, "");
    var data_array = p2.split(" ");
    data_array.shift();
    data_array.pop();
    return data_array;
  }

  function altcsrLists() {
    //******* need to match customer to csr and day
    var csrs = document.getElementById("usualcsrs").innerHTML;
    var days = document.getElementById("altcsrs_days").innerHTML;
    var shiptos = document.getElementById("shiptos").innerHTML;
    var customers = document.getElementById("customers").innerHTML;
    var csr_array = getData(csrs);
    var day_array = getData(days);
    var shipto_array = getData(shiptos);
    var customer_array = getData(customers);
    var csr_list = document.getElementById("altcsr_usualcsr");
    var csr = csr_list.options[csr_list.selectedIndex].text;
    var day_list = document.getElementById("altcsr_altcsrs_day");
    var day = day_list.options[day_list.selectedIndex].text;
    var customerlength = customer_array.length;
    var customer = document.getElementById("altcsr_custcode");
    var customer_id = ' ';
    var o = document.createElement("option");
    var sortarray = [];
    var i = 0;
    customer.options.length = 0;

    for (i = 0; i < customerlength; i++) {
      if (csr_array[i] == csr && day_array[i] == day) {
        if (sortarray.includes(customer_array[i]) == false) {
          sortarray[sortarray.length] = customer_array[i];
        }
      }
    }
    sortarray.sort();
    var sortlength = sortarray.length;
    o.selected = true;
    customer_id = sortarray[0];
    for (i = 0; i < sortlength; i++) {
      o.text = sortarray[i];
      customer.options.add(o, customer.options.length);
      o.selected = false;
      o = document.createElement("option");
    }

    var shipto = document.getElementById("altcsr_shipto");
    o = document.createElement("option");
    sortarray = [];
    i = 0;
    shipto.options.length = 0;

    for (i = 0; i < customerlength; i++) {
      if (csr_array[i] == csr && day_array[i] == day && customer_array[i] == customer_id) {
        if (sortarray.includes(shipto_array[i]) == false) {
          sortarray[sortarray.length] = shipto_array[i];
        }
      }
    }
    sortarray.sort();
    var sortlength = sortarray.length;

    for (i = 0; i < sortlength; i++) {
      o.text = sortarray[i];
      shipto.options.add(o, shipto.options.length);
      o = document.createElement("option");
    }
  }

  function dontSellLists() {
    //******* need to match part list to customer
    var descs = document.getElementById("descs").innerHTML;
    var parts = document.getElementById("parts").innerHTML;
    var customers = document.getElementById("customers").innerHTML;
    var customersA = document.getElementById("customersA").innerHTML;
    var desc_array = getData(descs);
    var part_array = getData(parts);
    var customer_array = getData(customers);
    var customerA_array = getData(customersA);
    var customer_list = document.getElementById("dont_sell_customer");
    var customer = customer_list.options[customer_list.selectedIndex].text;
    var customerlength = customer_array.length;
    var customerAlength = customerA_array.length;
    var partlength = part_array.length;

    var part = document.getElementById("dont_sell_part");
    var o = document.createElement("option");
    var sortarray = [];
    var sortarray2 = [];
    var i = 0;
    part.options.length = 0;

    for (i = 0; i < customerAlength; i++) {
      if (customerA_array[i] == customer) {
        if (sortarray.includes(part_array[i]) == false) {
          k = sortarray.length
          sortarray[sortarray.length] = part_array[i];
          sortarray2[k] = desc_array[i];
        }
      }
    }
    sortlength = sortarray.length;

    for (i = 0; i < sortlength; i++) {
      o.text = sortarray[i];
      part.options.add(o, part.options.length);
      o = document.createElement("option");
    }
    document.getElementById("partdesc").innerHTML = sortarray2[0].replace(/~/g, ' ');
  }

  function dontSellDesc() {
    var parts = document.getElementById("parts").innerHTML;
    var part_array = getData(parts);
    var descs = document.getElementById("descs").innerHTML;
    var desc_array = getData(descs);
    var part = document.getElementById("dont_sell_part");
    var partcode = part.options[part.selectedIndex].text;
    var partlength = part_array.length;
    var i = 0;
    for (i = 0; i < partlength; i++) {
      if (part_array[i] == partcode) {
        document.getElementById("partdesc").innerHTML = desc_array[i].replace(/~/g, ' ');
        i = partlength + 1;
      }
    }
  }

  function onSpecialLists() {
    //******* need to match part list to customer
    var descs = document.getElementById("descs").innerHTML;
    var parts = document.getElementById("parts").innerHTML;
    var customers = document.getElementById("customers").innerHTML;
    var customersA = document.getElementById("customersA").innerHTML;
    var desc_array = getData(descs);
    var part_array = getData(parts);
    var customer_array = getData(customers);
    var customerA_array = getData(customersA);
    var customer_list = document.getElementById("on_special_customer");
    var customer = customer_list.options[customer_list.selectedIndex].text;
    var customerlength = customer_array.length;
    var customerAlength = customerA_array.length;
    var partlength = part_array.length;

    var part = document.getElementById("on_special_part");
    var o = document.createElement("option");
    var sortarray = [];
    var sortarray2 = [];
    var i = 0;
    part.options.length = 0;

    for (i = 0; i < customerAlength; i++) {
      if (customerA_array[i] == customer || customer == 'ALL') {
        if (sortarray.includes(part_array[i]) == false) {
          k = sortarray.length
          sortarray[sortarray.length] = part_array[i];
          sortarray2[k] = desc_array[i];
        }
      }
    }
    sortlength = sortarray.length;

    for (i = 0; i < sortlength; i++) {
      o.text = sortarray[i];
      part.options.add(o, part.options.length);
      o = document.createElement("option");
    }
    document.getElementById("partdesc").innerHTML = sortarray2[0].replace(/~/g, ' ');
  }

  function onSpecialDesc() {
    var parts = document.getElementById("parts").innerHTML;
    var part_array = getData(parts);
    var descs = document.getElementById("descs").innerHTML;
    var desc_array = getData(descs);
    var part = document.getElementById("on_special_part");
    var partcode = part.options[part.selectedIndex].text;
    var partlength = part_array.length;
    var i = 0;
    for (i = 0; i < partlength; i++) {
      if (part_array[i] == partcode) {
        document.getElementById("partdesc").innerHTML = desc_array[i].replace(/~/g, ' ');
        i = partlength + 1;
      }
    }
  }
