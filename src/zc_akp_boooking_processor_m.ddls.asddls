@EndUserText.label: 'Booking Projection View - Processor app'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true

define view entity ZC_AKP_BOOOKING_PROCESSOR_M
  as projection on ZI_AKP_BOOOKING_M
{
  key TravelId,
  key BookingId,
      BookingDate,
      @ObjectModel.text.element: [ 'CustomerName' ]
      CustomerId,
      _Customer.LastName        as CustomerName,
      @ObjectModel.text.element: [ 'CarrierName' ]
      CarrierId,
      _Carrier.Name             as CarrierName,
      ConnectionId,
      FlightDate,
      FlightPrice,
      CurrencyCode,
      @ObjectModel.text.element: [ 'BookingStatusText' ]
      BookingStatus,
      _BookingStatus._Text.Text as BookingStatusText : localized,
      LastChangedAt,
      /* Associations */
      _BookingStatus,
      _BookingSupplement : redirected to composition child ZC_AKP_BOOKSUPPL_PROCESSOR_M,
      _Carrier,
      _Connection,
      _Customer,
      _Travel            : redirected to parent ZC_AKP_TRAVEL_PROCESSOR_M
}
