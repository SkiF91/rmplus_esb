class Resb::Proxy::Core::Body < Resb::Proxy::Core::Base
  attr_accessor :target, :first, :previous
  attr_accessor :message_id, name: :id

  def self.node_name
    self.name.demodulize.underscore.to_s
  end

  def payload
    @payload
  end

  def payload=(value)
    @payload = value
  end

  def handle
  end

  # ActiveSupport::XMLConverter
  # use Traits\ProxyObject;
  #
  # protected static $clearPattern = '#[^-_ёа-яa-z0-9\\s\.+@]#iu';

  # /**
  #        * Чистит строку от всех запрещенных символов
  #        *
  #        * @param $string
  #        *
  #        * @return string
  #        */
  # public function clearString($string) {
  #   return trim(preg_replace(static::$clearPattern, '', $string));
  # }
  #
  # /**
  #        * Функция для преобразования колонок типа datetime. Для передачи информации о дате и времени без часовой зоны.
  #        * Это поля, вроде времени готовности заказа. Например - время доставки, которое указал клиент в форме на сайте.
  #        * При вызове на сервере с timezone = Asia/Vladivostok,
  #     * строка "2016-11-21 15:00:00+3:00" преобразуется в  "2016-11-21T22:00:00",
  #                                                          * строка "2016-11-21 15:00:00" преобразуется в "2016-11-21T15:00:00",
  #                                                                                                         * строка "2016-11-21 15:00:00Z" или "2016-11-21 15:00:00UTC" преобразуется в "2016-11-22T03:00:00"
  # *
  # * @param string $dateTime Дата в строковом формате, который может быть интерпертирован функцией strtotime
  # *
  # * @return bool|string Возвращает строку в формате '2016-11-11T18:30:00'
  # */
  #       protected function toDateTime($dateTime) {
  #           return date('Y-m-d\TH:i:s', strtotime($dateTime));
  #       }
  #
  #       /**
  # * Функция для преобразования колонок типа timestamp. Для передачи информации с временной зоной.
  #     * Это поля, вроде времени создания документа и т.п. Т.е. такие атрибуты, которые могут создаваться
  # * на одном сервере, но должны корректно интерпретироваться на другом в другой часовой зоне для понимания,
  #                                                                                                * когда именно произошло событие.
  #     * При вызове на сервере с timezone = Asia/Vladivostok,
  #                               * строка "2016-11-21 15:00:00+3:00" преобразуется в  "2016-11-21T22:00:00+10:00",
  #                                                                                    * строка "2016-11-21 15:00:00" преобразуется в "2016-11-21T15:00:00+10:00",
  #                                                                                                                                   * строка "2016-11-21 15:00:00Z" или "2016-11-21 15:00:00UTC" преобразуется в "2016-11-22T03:00:00+10:00"
  # *
  # * @param string $dateTime Дата в строковом формате, который может быть интерпертирован функцией strtotime
  # *
  # * @return bool|string Возвращает строку в формате '2016-11-11T18:30:00+10:00'
  # */
  #       protected function toDateTimeGMT($dateTime) {
  #           return date('c', strtotime($dateTime));
  #       }
  #
  #       /**
  # * Функция для преобразования колонок типа timestamp. Для передачи информации с учетом зоны в UTC.
  #     * Это поля, вроде времени создания документа и т.п. Т.е. такие атрибуты, которые могут создаваться
  # * на одном сервере, но должны корректно интерпретироваться на другом в другой часовой зоне для понимания,
  #                                                                                                * когда именно произошло событие.
  #     * При вызове на сервере с timezone = Asia/Vladivostok,
  #                               * строка "2016-11-21 15:00:00+3:00" преобразуется в  "2016-11-21T12:00:00Z",
  #                                                                                    * строка "2016-11-21 15:00:00" преобразуется в "2016-11-21T05:00:00Z",
  #                                                                                                                                   * строка строка "2016-11-21 15:00:00Z" или "2016-11-21 15:00:00UTC" преобразуется в "2016-11-21T15:00:00Z"
  # *
  # * @param string $dateTime Дата в строковом формате, который может быть интерпертирован функцией strtotime
  # *
  # * @return bool|string Возвращает строку в формате '2016-11-11T18:30:00Z'
  # */
  #       protected function toDateTimeUTC($dateTime) {
  #           return gmdate('Y-m-d\TH:i:s\Z', strtotime($dateTime));
  #       }
  #
  #       /**
  # * Функция для преобразования колонок типа bool.
  #     *
  # * @param mixed $value Значение в формате
  # * - true|false
  # * - "true"|"false"
  # * - 1|0
  # *
  # * @return string Возвращает строку в формате "true"|"false"
  # */
  #       protected function toBool($value) {
  #           return (bool)$value == false || (is_string($value) && $value == "false") ? "false" : "true";
  #       }
end