CLASS lsc_zi_akp_travel_m DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_zi_akp_travel_m IMPLEMENTATION.

  METHOD save_modified.
********************************************************************************
* Implements additional save
********************************************************************************
    DATA travel_log_delete TYPE STANDARD TABLE OF zakp_log_trvl_m.
    DATA travel_log_create TYPE STANDARD TABLE OF zakp_log_trvl_m.
    DATA travel_log_update TYPE STANDARD TABLE OF zakp_log_trvl_m.

    " (1) Get instance data of all instances that have been created
    IF create-travel IS NOT INITIAL.
      LOOP AT create-travel ASSIGNING FIELD-SYMBOL(<travel_create>).

        GET TIME STAMP FIELD DATA(ts1).

        " If new value of the booking_fee field created
        IF <travel_create>-%control-BookingFee = cl_abap_behv=>flag_changed.
          APPEND VALUE zakp_log_trvl_m(
                      travelid = <travel_create>-TravelId
                      changing_operation = 'CREATE'
                      created_at = ts1
                      change_id = cl_system_uuid=>create_uuid_x16_static( )
                      changed_field_name = 'booking_fee'
                      changed_value = <travel_create>-BookingFee
           ) TO travel_log_create.
        ENDIF.

        " If new value of the overall_status field created
        IF <travel_create>-%control-OverallStatus = cl_abap_behv=>flag_changed.
          APPEND VALUE zakp_log_trvl_m(
                      travelid = <travel_create>-TravelId
                      changing_operation = 'CREATE'
                      created_at = ts1
                      change_id = cl_system_uuid=>create_uuid_x16_static( )
                      changed_field_name = 'overall_status'
                      changed_value = <travel_create>-OverallStatus
           ) TO travel_log_create.
        ENDIF.

        " IF  <travel_create>-%control-...

      ENDLOOP.

      " Inserts rows specified in travel_log_create into the DB table zakp_log_trvl_m
      INSERT zakp_log_trvl_m FROM TABLE @travel_log_create.

    ENDIF.

    " (2) Get instance data of all instances that have been updated during the transaction

    IF update-travel IS NOT INITIAL.
      LOOP AT update-travel ASSIGNING FIELD-SYMBOL(<travel_update>).

        GET TIME STAMP FIELD ts1.


        IF <travel_update>-%control-CustomerId = if_abap_behv=>mk-on.
          APPEND VALUE zakp_log_trvl_m(
                      travelid = <travel_update>-TravelId
                      changing_operation = 'UPDATE'
                      created_at = ts1
                      change_id = cl_system_uuid=>create_uuid_x16_static( )
                      changed_field_name = 'customer_id'
                      changed_value = <travel_update>-CustomerId
           ) TO travel_log_update.
        ENDIF.


        IF <travel_update>-%control-description = cl_abap_behv=>flag_changed.
          APPEND VALUE zakp_log_trvl_m(
                      travelid = <travel_update>-TravelId
                      changing_operation = 'UPDATE'
                      created_at = ts1
                      change_id = cl_system_uuid=>create_uuid_x16_static( )
                      changed_field_name = 'description'
                      changed_value = <travel_update>-description
           ) TO travel_log_update.
        ENDIF.

        " IF  <travel_update>-%control-...

      ENDLOOP.

      " Inserts rows specified in travel_log_update into the DB table zakp_log_trvl_m
      INSERT zakp_log_trvl_m FROM TABLE @travel_log_update.

    ENDIF.


    " (3) Get keys of all travel instances that have been deleted during the transaction
    IF delete-travel IS NOT INITIAL.
      LOOP AT delete-travel ASSIGNING FIELD-SYMBOL(<travel_delete>).

        GET TIME STAMP FIELD ts1.

        APPEND VALUE zakp_log_trvl_m(
            travelid = <travel_delete>-TravelId
            changing_operation = 'DELETE'
            created_at = ts1
            change_id = cl_system_uuid=>create_uuid_x16_static( )
         ) TO travel_log_delete.


      ENDLOOP.

      " Inserts rows specified in travel_log_delete into the DB table zakp_log_trvl_m
      INSERT zakp_log_trvl_m FROM TABLE @travel_log_delete.
    ENDIF.

********************************************************************************
*
* Implements unmanaged save     ---Please also refer to class /DMO/BP_TRAVEL_M
*
********************************************************************************
    DATA booksuppls_db TYPE STANDARD TABLE OF zakp_booksuppl_m.

    " (1) Get instance data of all instances that have been created
    IF create-bookingsuppl IS NOT INITIAL.
      booksuppls_db = CORRESPONDING #( create-bookingsuppl MAPPING FROM ENTITY ).
      INSERT zakp_booksuppl_m FROM TABLE @booksuppls_db. " Any legacy code- BAPI,FN module etc..
    ENDIF.

    " (2) Get instance data of all instances that have been updated during the transaction
    IF update-bookingsuppl IS NOT INITIAL.
      "To optimize this we can only update fields marked in %control --refer class /DMO/BP_TRAVEL_M
      booksuppls_db = CORRESPONDING #( update-bookingsuppl MAPPING FROM ENTITY ).
      UPDATE zakp_booksuppl_m FROM TABLE @booksuppls_db. " Any legacy code- BAPI,FN module etc..
    ENDIF.

    " (3) Get keys of all travel instances that have been deleted during the transaction
    IF delete-bookingsuppl IS NOT INITIAL.
      booksuppls_db = CORRESPONDING #( delete-bookingsuppl MAPPING FROM ENTITY ).
      DELETE zakp_booksuppl_m FROM TABLE @booksuppls_db. " Any legacy code- BAPI,FN module etc..
    ENDIF.

  ENDMETHOD.

ENDCLASS.

CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Travel RESULT result.
    METHODS accepttravel FOR MODIFY
      IMPORTING keys FOR ACTION travel~accepttravel RESULT result.

    METHODS copytravel FOR MODIFY
      IMPORTING keys FOR ACTION travel~copytravel.

    METHODS recalctotalprice FOR MODIFY
      IMPORTING keys FOR ACTION travel~recalctotalprice.

    METHODS rejecttravel FOR MODIFY
      IMPORTING keys FOR ACTION travel~rejecttravel RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR travel RESULT result.
    METHODS validatedates FOR VALIDATE ON SAVE
      IMPORTING keys FOR travel~validatedates.
    METHODS validateagency FOR VALIDATE ON SAVE
      IMPORTING keys FOR travel~validateagency.

    METHODS validatecurrencycode FOR VALIDATE ON SAVE
      IMPORTING keys FOR travel~validatecurrencycode.

    METHODS validatecustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR travel~validatecustomer.

    METHODS validatestatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR travel~validatestatus.
    METHODS calucatetotalprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR travel~calucatetotalprice.

    METHODS earlynumbering_cba_booking FOR NUMBERING
      IMPORTING entities FOR CREATE travel\_booking.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE travel.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD earlynumbering_create.
    DATA(lt_entities) = entities.

    "Deleting entries where TravelId is already filled.
    "This usually happens in draft scenario where this method is called twice.
    DELETE lt_entities WHERE TravelId IS NOT INITIAL.
    CHECK lt_entities IS NOT INITIAL.

    TRY.
        cl_numberrange_runtime=>number_get(
          EXPORTING
            nr_range_nr       = '01'
            object            = 'ZAKP_NR_TR'
            quantity          = CONV #( lines( lt_entities ) )
          IMPORTING
            number            = DATA(lv_next_number)
            returncode        = DATA(lv_return_code)
            returned_quantity = DATA(lv_qty)
        ).

      CATCH cx_nr_object_not_found cx_number_ranges INTO DATA(lo_exception).

        LOOP AT lt_entities ASSIGNING FIELD-SYMBOL(<entity>).
          APPEND INITIAL LINE TO failed-travel ASSIGNING FIELD-SYMBOL(<fail>).
          <fail>-%cid = <entity>-%cid.
          <fail>-%key = <entity>-%key.

          APPEND INITIAL LINE TO reported-travel ASSIGNING FIELD-SYMBOL(<reported>).
          <reported>-%cid = <entity>-%cid.
          <reported>-%key = <entity>-%key.
          <reported>-%msg = lo_exception.
        ENDLOOP.

        EXIT.
    ENDTRY.

    ASSERT lv_qty = lines( lt_entities ).

    DATA(lv_current_num) =  lv_next_number - lv_qty.

    LOOP AT lt_entities ASSIGNING FIELD-SYMBOL(<ls_entity>).
      lv_current_num = lv_current_num + 1.

      APPEND INITIAL LINE TO mapped-travel ASSIGNING FIELD-SYMBOL(<ls_mapped_travel>).
      <ls_mapped_travel>-%cid = <ls_entity>-%cid.
      <ls_mapped_travel>-%key-TravelId = lv_current_num.

    ENDLOOP.

  ENDMETHOD.

  METHOD earlynumbering_cba_Booking.

    READ ENTITIES OF zi_akp_travel_m IN LOCAL MODE
    ENTITY Travel BY \_Booking
    FROM CORRESPONDING #( entities )
    LINK DATA(lt_link_data).

    " Loop over all unique TravelIDs
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<travel_group>)
    GROUP BY <travel_group>-TravelId.
      " Get highest booking_id from bookings belonging to travel
      DATA(lv_max_booking_id) = REDUCE #( INIT max_booking_id TYPE /dmo/booking_id
                                          FOR ls_link IN lt_link_data USING KEY entity WHERE ( source-TravelId = <travel_group>-TravelId )
                                          NEXT max_booking_id = COND #( WHEN ls_link-target-BookingId > max_booking_id
                                                                        THEN ls_link-target-BookingId
                                                                        ELSE max_booking_id )
                                          ).
      " Get highest assigned booking_id from incoming entities
      lv_max_booking_id = REDUCE #( INIT max_booking_id = lv_max_booking_id
                                    FOR ls_entity IN entities USING KEY entity WHERE ( TravelId = <travel_group>-TravelId )
                                    FOR ls_target_booking IN ls_entity-%target
                                    NEXT max_booking_id = COND #( WHEN ls_target_booking-BookingId > max_booking_id
                                                                  THEN ls_target_booking-BookingId
                                                                  ELSE max_booking_id )
                                  ).

      " Loop over all entries in entities with the same TravelID
      LOOP AT GROUP <travel_group> ASSIGNING FIELD-SYMBOL(<travel_grp_line>).
        " Assign new booking-ids if not already assigned
        LOOP AT <travel_grp_line>-%target ASSIGNING FIELD-SYMBOL(<booking_without_numbers>)
                        WHERE BookingId IS INITIAL.

          APPEND CORRESPONDING #( <booking_without_numbers> ) TO mapped-booking ASSIGNING FIELD-SYMBOL(<mapped_booking>).
          lv_max_booking_id += 10.
          <mapped_booking>-BookingId = lv_max_booking_id.

        ENDLOOP.
      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.


  METHOD acceptTravel.
    " Modify in local mode: BO-related updates that are not relevant for authorization checks
    MODIFY ENTITIES OF zi_akp_travel_m  IN LOCAL MODE
        ENTITY Travel
            UPDATE FIELDS ( OverallStatus )
                WITH VALUE #( FOR ls_key IN keys ( %tky-TravelId = ls_key-%tky-TravelId
                                        %data-OverallStatus = 'A'  ) )
    FAILED FINAL(lt_fAILED)
    MAPPED FINAL(lt_mapped).

    " Read changed data for action result
    READ ENTITIES OF zi_akp_travel_m IN LOCAL MODE
        ENTITY Travel
            ALL FIELDS WITH
            CORRESPONDING #( keys )
    RESULT FINAL(lt_travels).

    result = VALUE #( FOR ls_travel IN lt_travels ( %tky = ls_travel-%tky
                                                    %param = ls_travel
                                                     ) ).

  ENDMETHOD.

  METHOD rejectTravel.
    " Modify in local mode: BO-related updates that are not relevant for authorization checks
    MODIFY ENTITIES OF zi_akp_travel_m  IN LOCAL MODE
        ENTITY Travel
            UPDATE FIELDS ( OverallStatus )
                WITH VALUE #( FOR ls_key IN keys ( %tky-TravelId = ls_key-%tky-TravelId
                                        %data-OverallStatus = 'X' ) )
    FAILED FINAL(lt_fAILED)
    MAPPED FINAL(lt_mapped).

    " Read changed data for action result
    READ ENTITIES OF zi_akp_travel_m IN LOCAL MODE
        ENTITY Travel
            ALL FIELDS WITH
            CORRESPONDING #( keys )
    RESULT FINAL(lt_travels).

    result = VALUE #( FOR ls_travel IN lt_travels ( %tky = ls_travel-%tky
                                                    %param = ls_travel
                                                     ) ).
  ENDMETHOD.

  METHOD copyTravel.
    DATA: lt_create_travel TYPE TABLE FOR CREATE zi_akp_travel_m\\Travel.
    DATA: lt_cba_bookings TYPE TABLE FOR CREATE zi_akp_travel_m\\Travel\_Booking.
    DATA: lt_cba_bookSupplements TYPE TABLE FOR CREATE zi_akp_travel_m\\Booking\_BookingSupplement.


    READ TABLE keys WITH KEY %cid = '' ASSIGNING FIELD-SYMBOL(<lfs_key_without_cid>).
    ASSERT <lfs_key_without_cid> IS NOT ASSIGNED.

    READ ENTITIES OF zi_akp_travel_m IN LOCAL MODE
        ENTITY Travel
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT FINAL(lt_read_travels)

        ENTITY Travel BY \_Booking
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT FINAL(lt_read_bookings).

    IF lt_read_bookings IS NOT INITIAL.
      READ ENTITIES OF zi_akp_travel_m IN LOCAL MODE
          ENTITY Booking BY \_BookingSupplement
          ALL FIELDS WITH CORRESPONDING #( lt_read_bookings )
          RESULT FINAL(lt_read_bookingSupplements).
    ENDIF.


    LOOP AT lt_read_travels ASSIGNING FIELD-SYMBOL(<ls_read_travel>).

      "Prepare Travel Data
      APPEND VALUE #( %cid = keys[ KEY entity TravelId = <ls_read_travel>-TravelId ]-%cid
                       %data = CORRESPONDING #( <ls_read_travel> EXCEPT TravelId )
                     )
                    TO lt_create_travel ASSIGNING FIELD-SYMBOL(<ls_travel_new>).

      <ls_travel_new>-BeginDate = cl_abap_context_info=>get_system_date( ).
      <ls_travel_new>-EndDate = cl_abap_context_info=>get_system_date( ) + 30.
      <ls_travel_new>-OverallStatus = 'O'.
      <ls_travel_new>-Description = |Copy of { <ls_read_travel>-TravelId ALPHA = OUT }:{ <ls_read_travel>-Description }|.

      "Prepare Booking Data
      APPEND VALUE #( %cid_ref = <ls_travel_new>-%cid )
                    TO lt_cba_bookings ASSIGNING FIELD-SYMBOL(<ls_cba_booking_new>).

      LOOP AT lt_read_bookings ASSIGNING FIELD-SYMBOL(<ls_read_booking>)
                  USING KEY entity WHERE TravelId = <ls_read_travel>-TravelId.

        APPEND VALUE #( %cid = <ls_travel_new>-%cid && <ls_read_booking>-BookingId
                        %data = CORRESPONDING #( <ls_read_booking> EXCEPT TravelId BookingId )
                        )
            TO <ls_cba_booking_new>-%target ASSIGNING FIELD-SYMBOL(<ls_cba_booking_target_new>).

        <ls_cba_booking_target_new>-BookingStatus = 'N'.

        "Prepare Booking Supplement Data.
        APPEND VALUE #( %cid_ref = <ls_cba_booking_target_new>-%cid )
                         TO lt_cba_bookSupplements ASSIGNING FIELD-SYMBOL(<ls_cba_bookSupp_new>).

        LOOP AT lt_read_bookingsupplements ASSIGNING FIELD-SYMBOL(<ls_read_bookingsupplements>)
                USING KEY entity WHERE TravelId = <ls_read_travel>-TravelId
                                  AND  BookingId = <ls_read_booking>-BookingId.

          APPEND VALUE #( %cid = <ls_travel_new>-%cid && <ls_read_booking>-BookingId && <ls_read_bookingsupplements>-BookingSupplementId
                          %data = CORRESPONDING #( <ls_read_bookingsupplements> EXCEPT TravelId BookingId BookingSupplementId )
                          )
            TO <ls_cba_booksupp_new>-%target ASSIGNING FIELD-SYMBOL(<ls_cba_bookSupp_target_new>).

        ENDLOOP.



      ENDLOOP.
    ENDLOOP.

    "create new BO instance
    MODIFY ENTITIES OF zi_akp_travel_m IN LOCAL MODE
     ENTITY Travel
         CREATE
         FIELDS ( agencyid customerid begindate enddate bookingfee totalprice currencycode description overallstatus )
         WITH lt_create_travel

         CREATE BY \_Booking
         FIELDS ( bookingdate customerid carrierid connectionid flightdate flightprice currencycode bookingstatus )
         WITH lt_cba_bookings

     ENTITY Booking
        CREATE BY \_BookingSupplement
        FIELDS ( SupplementId Price CurrencyCode )
        WITH lt_cba_bookSupplements

     MAPPED FINAL(lt_mapped)
     FAILED FINAL(lt_failed)
     REPORTED FINAL(lt_reported).

    mapped-travel = lt_mapped-travel.

  ENDMETHOD.


  METHOD reCalcTotalPrice.
    TYPES: BEGIN OF ty_amt_per_currency,
             amount        TYPE /dmo/total_price,
             currency_code TYPE /dmo/currency_code,
           END OF ty_amt_per_currency.

    DATA: lt_amt_per_currencycode TYPE STANDARD TABLE OF ty_amt_per_currency.

*    DATA: lt_upd_travel TYPE TABLE FOR UPDATE zi_akp_travel_m\\Travel.

    READ ENTITIES OF zi_akp_travel_m IN LOCAL MODE
        ENTITY Travel
        FIELDS ( BookingFee CurrencyCode )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_travels)

        ENTITY Travel BY \_Booking
        FIELDS ( FlightPrice CurrencyCode )
        WITH CORRESPONDING #( keys )
        RESULT FINAL(lt_bookings).

    IF lt_bookings IS NOT INITIAL.
      READ ENTITIES OF zi_akp_travel_m IN LOCAL MODE
      ENTITY Booking BY \_BookingSupplement
      FIELDS ( Price CurrencyCode )
      WITH CORRESPONDING #( lt_bookings )
      RESULT FINAL(lt_bookSupplements).
    ENDIF.

    LOOP AT lt_travels ASSIGNING FIELD-SYMBOL(<travel>).

      lt_amt_per_currencycode = VALUE #( ( amount = <travel>-BookingFee
                                           currency_code = <travel>-CurrencyCode ) ).

      LOOP AT lt_bookings ASSIGNING FIELD-SYMBOL(<booking>)
                    USING KEY entity
                    WHERE TravelId = <travel>-TravelId .

        lt_amt_per_currencycode = VALUE #( BASE lt_amt_per_currencycode (
                                                                    amount = <booking>-FlightPrice
                                                                    currency_code = <booking>-CurrencyCode
                                                                    ) ).

        LOOP AT lt_booksupplements ASSIGNING FIELD-SYMBOL(<bookSuppl>)
            USING KEY entity
            WHERE TravelId = <travel>-%tky-TravelId AND BookingId = <booking>-%tky-BookingId.
          lt_amt_per_currencycode = VALUE #( BASE lt_amt_per_currencycode (
                                                                      amount = <bookSuppl>-Price
                                                                      currency_code = <bookSuppl>-CurrencyCode
                                                                      ) ).

        ENDLOOP.


      ENDLOOP.

      CLEAR: <travel>-TotalPrice.

      LOOP AT lt_amt_per_currencycode ASSIGNING FIELD-SYMBOL(<amt_per_currency>).

        <travel>-TotalPrice += <amt_per_currency>-amount.
      ENDLOOP.
    ENDLOOP.


*Modify the Total price
    MODIFY ENTITIES OF zi_akp_travel_m IN LOCAL MODE
        ENTITY Travel
        UPDATE FIELDS ( TotalPrice )
        WITH CORRESPONDING #( lt_travels )
        FAILED FINAL(lt_failed).





  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF zi_akp_travel_m IN LOCAL MODE
        ENTITY Travel
            FIELDS ( TravelId OverallStatus )
            WITH CORRESPONDING #( keys )
         RESULT FINAL(lt_travels).

    result = VALUE #( FOR ls_travel IN lt_travels
                        (
                          %tky = ls_travel-%tky
                          %features-%action-acceptTravel = COND #( WHEN ls_travel-OverallStatus EQ 'A'
                                                                    THEN if_abap_behv=>fc-o-disabled
                                                                    ELSE if_abap_behv=>fc-o-enabled )
                          %features-%action-rejectTravel = COND #( WHEN ls_travel-OverallStatus EQ 'X'
                                                                    THEN if_abap_behv=>fc-o-disabled
                                                                    ELSE if_abap_behv=>fc-o-enabled )
                          %features-%assoc-_Booking =      COND #( WHEN ls_travel-OverallStatus EQ 'X'
                                                                    THEN if_abap_behv=>fc-o-disabled
                                                                    ELSE if_abap_behv=>fc-o-enabled )

                         ) ).


  ENDMETHOD.



  METHOD validateDates.
    READ ENTITIES OF zi_akp_travel_m IN LOCAL MODE
        ENTITY Travel
            FIELDS ( BeginDate EndDate )
            WITH CORRESPONDING #( keys )
            RESULT FINAL(lt_travels).

    LOOP AT lt_travels ASSIGNING FIELD-SYMBOL(<ls_travel>).
      IF <ls_travel>-EndDate LT <ls_travel>-BeginDate.

        APPEND VALUE #( %tky = <ls_travel>-%tky ) TO failed-travel. "end_date before begin_date

        APPEND VALUE #( %tky = <ls_travel>-%tky
                        %msg = NEW /dmo/cm_flight_messages(
                                      textid                = /dmo/cm_flight_messages=>begin_date_bef_end_date
                                      begin_date            = <ls_travel>-BeginDate
                                      end_date              = <ls_travel>-EndDate
                                      severity              = if_abap_behv_message=>severity-error )
                        %element-begindate = if_abap_behv=>mk-on
                        %element-enddate = if_abap_behv=>mk-on
                      ) TO reported-travel.

      ELSEIF <ls_travel>-BeginDate LT cl_abap_context_info=>get_system_date(  ). ""begin_date must be in the future
        APPEND VALUE #( %tky = <ls_travel>-%tky ) TO failed-travel. "end_date before begin_date

        APPEND VALUE #( %tky = <ls_travel>-%tky
                        %msg = NEW /dmo/cm_flight_messages(
                                      textid                = /dmo/cm_flight_messages=>begin_date_on_or_bef_sysdate
                                      severity              = if_abap_behv_message=>severity-error )
                        %element-begindate = if_abap_behv=>mk-on
                        %element-enddate = if_abap_behv=>mk-on
                      ) TO reported-travel.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD validateAgency.
    DATA lt_agencies TYPE SORTED TABLE OF /dmo/agency WITH UNIQUE KEY agency_id.

    " Read relevant travel instance data
    READ ENTITIES OF zi_akp_travel_m IN LOCAL MODE
       ENTITY Travel
         FIELDS ( AgencyId )
         WITH CORRESPONDING #( keys )
         RESULT FINAL(lt_travels).

    " Optimization of DB select: extract distinct non-initial agency IDs
    lt_agencies = CORRESPONDING #( lt_travels DISCARDING DUPLICATES MAPPING agency_id = AgencyId EXCEPT * ).
    DELETE lt_agencies WHERE agency_id IS INITIAL.

    IF lt_agencies IS NOT INITIAL.
      SELECT FROM /dmo/agency
          FIELDS agency_id
          FOR ALL ENTRIES IN @lt_agencies
          WHERE agency_id = @lt_agencies-agency_id
          INTO TABLE @FINAL(lt_agencies_db).
    ENDIF.

    " Raise msg for non existing and initial agency id
    LOOP AT lt_travels ASSIGNING FIELD-SYMBOL(<ls_travel>).

      IF <ls_travel>-AgencyId IS INITIAL
          OR NOT line_exists( lt_agencies_db[ agency_id = <ls_travel>-AgencyId ] ).

        APPEND VALUE #(  %tky = <ls_travel>-%tky ) TO failed-travel.
        APPEND VALUE #(  %tky = <ls_travel>-%tky
                         %msg      = NEW /dmo/cm_flight_messages(
                                          textid    = /dmo/cm_flight_messages=>agency_unkown
                                          agency_id = <ls_travel>-AgencyId
                                          severity  = if_abap_behv_message=>severity-error )
                         %element-agencyid = if_abap_behv=>mk-on
                      ) TO reported-travel.


      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD validateCurrencyCode.
  ENDMETHOD.

  METHOD validateCustomer.
    " Read relevant travel instance data
    READ ENTITIES OF zi_akp_travel_m IN LOCAL MODE
    ENTITY travel
     FIELDS ( CustomerId )
     WITH CORRESPONDING #(  keys )
    RESULT DATA(travels).

    DATA customers TYPE SORTED TABLE OF /dmo/customer WITH UNIQUE KEY customer_id.

    " Optimization of DB select: extract distinct non-initial customer IDs
    customers = CORRESPONDING #( travels DISCARDING DUPLICATES MAPPING customer_id = CustomerId EXCEPT * ).
    DELETE customers WHERE customer_id IS INITIAL.

    IF customers IS NOT INITIAL.
      " Check if customer ID exists
      SELECT FROM /dmo/customer FIELDS customer_id
        FOR ALL ENTRIES IN @customers
        WHERE customer_id = @customers-customer_id
        INTO TABLE @DATA(customers_db).
    ENDIF.
    " Raise msg for non existing and initial customer id
    LOOP AT travels INTO DATA(travel).
      IF travel-CustomerId IS INITIAL
         OR NOT line_exists( customers_db[ customer_id = travel-CustomerId ] ).

        APPEND VALUE #(  %tky = travel-%tky ) TO failed-travel.
        APPEND VALUE #(  %tky = travel-%tky
                         %msg      = NEW /dmo/cm_flight_messages(
                                         customer_id = travel-CustomerId
                                         textid      = /dmo/cm_flight_messages=>customer_unkown
                                         severity    = if_abap_behv_message=>severity-error )
                         %element-CustomerId = if_abap_behv=>mk-on
                      ) TO reported-travel.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD validateStatus.
    READ ENTITIES OF zi_akp_travel_m IN LOCAL MODE
        ENTITY Travel
        FIELDS ( OverallStatus )
        WITH CORRESPONDING #( keys )
        RESULT FINAL(lt_travels).

    LOOP AT lt_travels ASSIGNING FIELD-SYMBOL(<ls_travel>).
      CASE <ls_travel>-OverallStatus.
        WHEN 'O'.  " Open
        WHEN 'X'.  " Cancelled
        WHEN 'A'.  " Accepted

        WHEN OTHERS.
          APPEND VALUE #( %tky = <ls_travel>-%tky ) TO failed-travel.

          APPEND VALUE #( %tky = <ls_travel>-%tky
                          %msg = NEW /dmo/cm_flight_messages(
                                     textid = /dmo/cm_flight_messages=>status_invalid
                                     severity = if_abap_behv_message=>severity-error
                                     status = <ls_travel>-OverallStatus )
                          %element-OverallStatus = if_abap_behv=>mk-on
                        ) TO reported-travel.
      ENDCASE.

    ENDLOOP.



  ENDMETHOD.



  METHOD calucateTotalPrice.
    MODIFY ENTITIES OF zi_akp_travel_m IN LOCAL MODE
    ENTITY Travel
    EXECUTE reCalcTotalPrice
    FROM CORRESPONDING #( keys ).
  ENDMETHOD.










































ENDCLASS.
