*&---------------------------------------------------------------------*
*&  Include  zabapgit_object_srfc
*&---------------------------------------------------------------------*


CLASS lcl_object_srfc DEFINITION INHERITING FROM lcl_objects_super FINAL.

  PUBLIC SECTION.
    INTERFACES lif_object.

ENDCLASS.

CLASS lcl_object_srfc IMPLEMENTATION.

  METHOD lif_object~has_changed_since.

    rv_changed = abap_true.

  ENDMETHOD.

  METHOD lif_object~changed_by.

    rv_user = c_user_unknown.

  ENDMETHOD.

  METHOD lif_object~get_metadata.

    rs_metadata = get_metadata( ).
    rs_metadata-delete_tadir = abap_true.

  ENDMETHOD.

  METHOD lif_object~exists.

    DATA: lo_object_data  TYPE REF TO if_wb_object_data_model,
          lo_srfc_persist TYPE REF TO if_wb_object_persist.

    TRY.
        CREATE OBJECT lo_srfc_persist TYPE ('CL_UCONRFC_OBJECT_PERSIST').

        lo_srfc_persist->get(
          EXPORTING
            p_object_key  = |{ ms_item-obj_name }|
            p_version     = 'A'
          CHANGING
            p_object_data = lo_object_data ).

      CATCH cx_root.
        rv_bool = abap_false.
        RETURN.
    ENDTRY.

    rv_bool = abap_true.

  ENDMETHOD.

  METHOD lif_object~serialize.

    DATA: lo_object_data  TYPE REF TO if_wb_object_data_model,
          lo_srfc_persist TYPE REF TO if_wb_object_persist,
          lr_srfc_data    TYPE REF TO data,
          lx_error        TYPE REF TO cx_root,
          lv_text         TYPE string.

    FIELD-SYMBOLS: <ls_srfc_data> TYPE any.

    TRY.
        CREATE DATA lr_srfc_data TYPE ('UCONRFCSERV_COMPLETE').
        ASSIGN lr_srfc_data->* TO <ls_srfc_data>.
        ASSERT sy-subrc = 0.

        CREATE OBJECT lo_srfc_persist TYPE ('CL_UCONRFC_OBJECT_PERSIST').

        lo_srfc_persist->get(
          EXPORTING
            p_object_key  = |{ ms_item-obj_name }|
            p_version     = 'A'
          CHANGING
            p_object_data = lo_object_data ).

        lo_object_data->get_data(
          IMPORTING
            p_data = <ls_srfc_data> ).

      CATCH cx_root INTO lx_error.
        lv_text = lx_error->get_text( ).
        zcx_abapgit_exception=>raise( lv_text ).
    ENDTRY.

    io_xml->add( iv_name = 'SRFC'
                 ig_data = <ls_srfc_data> ).

  ENDMETHOD.

  METHOD lif_object~deserialize.

    DATA: lo_srfc_persist TYPE REF TO if_wb_object_persist,
          lo_object_data  TYPE REF TO if_wb_object_data_model,
          lv_text         TYPE string,
          lr_srfc_data    TYPE REF TO data,
          lx_error        TYPE REF TO cx_root.

    FIELD-SYMBOLS: <ls_srfc_data> TYPE any.

    TRY.
        CREATE DATA lr_srfc_data TYPE ('UCONRFCSERV_COMPLETE').
        ASSIGN lr_srfc_data->* TO <ls_srfc_data>.
        ASSERT sy-subrc = 0.

        io_xml->read(
          EXPORTING
            iv_name = 'SRFC'
          CHANGING
            cg_data = <ls_srfc_data> ).

        CREATE OBJECT lo_srfc_persist TYPE ('CL_UCONRFC_OBJECT_PERSIST').
        CREATE OBJECT lo_object_data TYPE ('CL_UCONRFC_OBJECT_DATA').

        lo_object_data->set_data( p_data = <ls_srfc_data> ).

        lo_srfc_persist->save( lo_object_data ).

        tadir_insert( iv_package ).

      CATCH cx_root INTO lx_error.
        lv_text = lx_error->get_text( ).
        zcx_abapgit_exception=>raise( lv_text ).
    ENDTRY.

  ENDMETHOD.

  METHOD lif_object~delete.

    DATA: lo_srfc_persist TYPE REF TO if_wb_object_persist,
          lx_error        TYPE REF TO cx_root,
          lv_text         TYPE string.

    TRY.
        CREATE OBJECT lo_srfc_persist TYPE ('CL_UCONRFC_OBJECT_PERSIST').

        lo_srfc_persist->delete( p_object_key = |{ ms_item-obj_name }|
                                 p_version    = 'A' ).

      CATCH cx_root INTO lx_error.
        lv_text = lx_error->get_text( ).
        zcx_abapgit_exception=>raise( lv_text ).
    ENDTRY.

  ENDMETHOD.


  METHOD lif_object~jump.

    CALL FUNCTION 'RS_TOOL_ACCESS'
      EXPORTING
        operation           = 'SHOW'
        object_name         = ms_item-obj_name    " Object Name
        object_type         = ms_item-obj_type    " Object Type
        in_new_window       = abap_true
      EXCEPTIONS
        not_executed        = 1
        invalid_object_type = 2
        OTHERS              = 3.

    IF sy-subrc <> 0.
      zcx_abapgit_exception=>raise( 'error from RS_TOOL_ACCESS' ).
    ENDIF.

  ENDMETHOD.

  METHOD lif_object~compare_to_remote_version.

    CREATE OBJECT ro_comparison_result TYPE lcl_comparison_null.

  ENDMETHOD.

ENDCLASS.
