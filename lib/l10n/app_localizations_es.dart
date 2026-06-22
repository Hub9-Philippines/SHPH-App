// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'SerbisyoHub PH';

  @override
  String get settings => 'Configuración';

  @override
  String get settingsSubtitle =>
      'Administre preferencias, cuenta y opciones de soporte.';

  @override
  String get language => 'Idioma';

  @override
  String get languageSubtitle => 'Elija el idioma utilizado en la aplicación';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get notificationsSubtitle =>
      'Revise actualizaciones de reservas, mensajes y pagos';

  @override
  String get darkMode => 'Modo oscuro';

  @override
  String get darkModeSubtitle => 'Cambie entre apariencia clara y oscura';

  @override
  String get account => 'Cuenta';

  @override
  String get security => 'Seguridad';

  @override
  String get securitySubtitle =>
      'Contraseña, actividad de inicio de sesión y configuración 2FA';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get editProfileSubtitle => 'Actualice su información personal';

  @override
  String get support => 'Soporte';

  @override
  String get sendFeedback => 'Enviar comentarios';

  @override
  String get sendFeedbackSubtitle =>
      'Abra un borrador de correo electrónico para compartir comentarios';

  @override
  String get termsOfService => 'Términos de servicio';

  @override
  String get termsOfServiceSubtitle => 'Lea nuestros términos y condiciones';

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get privacyPolicySubtitle => 'Lea nuestra política de privacidad';

  @override
  String get logOut => 'Cerrar sesión';

  @override
  String get logOutTitle => 'Cerrar sesión';

  @override
  String get logOutConfirm => '¿Está seguro de que desea cerrar sesión?';

  @override
  String get cancel => 'Cancelar';

  @override
  String get logOutAction => 'Cerrar sesión';

  @override
  String get currentLanguage => 'Idioma actual';

  @override
  String get chooseLanguage =>
      'Elija el idioma preferido para su experiencia en la aplicación.';

  @override
  String get notificationsPageTitle => 'Notificaciones';

  @override
  String get notificationsPageSubtitle =>
      'Actualizaciones sobre reservas, mensajes y pagos.';

  @override
  String get errorLoadingNotifications => 'Error al cargar notificaciones';

  @override
  String get errorLoadingSubtitle =>
      'Ocurrió un error al obtener sus actualizaciones.';

  @override
  String get noNotifications => 'Sin notificaciones';

  @override
  String get noNotificationsSubtitle => 'Está al día por ahora.';

  @override
  String get justNow => 'Ahora mismo';

  @override
  String get securityPageTitle => 'Seguridad';

  @override
  String get securityPageSubtitle =>
      'Proteja su cuenta, contraseña y acceso de inicio de sesión.';

  @override
  String get password => 'Contraseña';

  @override
  String get currentPassword => 'Contraseña actual';

  @override
  String get enterCurrentPassword => 'Ingrese la contraseña actual';

  @override
  String get newPassword => 'Nueva contraseña';

  @override
  String get enterNewPassword => 'Ingrese la nueva contraseña';

  @override
  String get confirmPassword => 'Confirmar contraseña';

  @override
  String get reEnterPassword => 'Vuelva a ingresar su nueva contraseña';

  @override
  String get changePassword => 'Cambiar contraseña';

  @override
  String get passwordChanged => 'Contraseña cambiada exitosamente';

  @override
  String get errorChangingPassword => 'Error al cambiar la contraseña: ';

  @override
  String get currentPasswordRequired => 'Se requiere la contraseña actual';

  @override
  String get newPasswordRequired => 'Se requiere la nueva contraseña';

  @override
  String get passwordMinLength =>
      'La contraseña debe tener al menos 8 caracteres';

  @override
  String get confirmPasswordRequired => 'Por favor confirme su contraseña';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get twoFactorAuth => 'Autenticación de dos factores';

  @override
  String get secureYourLogin => 'Asegure su inicio de sesión';

  @override
  String get secureYourLoginSubtitle =>
      'Use una aplicación de autenticación para agregar un segundo paso al iniciar sesión.';

  @override
  String get setup2FA => 'Configurar 2FA';

  @override
  String get scanQRCode =>
      'Escane este código QR con su aplicación de autenticación, luego ingrese el código de 6 dígitos para finalizar la configuración.';

  @override
  String get verificationCode => 'Código de verificación';

  @override
  String get verifyAndEnable => 'Verificar y activar';

  @override
  String get enterCode => 'Por favor ingrese el código de verificación';

  @override
  String get invalidCode => 'Código de verificación inválido: ';

  @override
  String get twoFAEnabled => '2FA activado exitosamente';

  @override
  String get twoFADisabled => '2FA desactivado exitosamente';

  @override
  String get errorEnrolling2FA => 'Error al inscribir 2FA: ';

  @override
  String get loginActivity => 'Actividad de inicio de sesión';

  @override
  String get currentDevice => 'Dispositivo actual';

  @override
  String get otherSignIn => 'Otro inicio de sesión';

  @override
  String get activeNow => 'Activo ahora';

  @override
  String get lastActive => 'Última actividad ';

  @override
  String get noSessions =>
      'Aún no se devolvieron sesiones activas para esta cuenta.';

  @override
  String get keepAccountProtected => 'Mantenga su cuenta protegida';

  @override
  String get keepAccountProtectedSubtitle =>
      'Administre la seguridad de la contraseña, 2FA y el acceso reciente a la cuenta en un solo lugar.';

  @override
  String get providerInbox => 'Bandeja de proveedor';

  @override
  String get pendingRequests => 'solicitud pendiente';

  @override
  String get pendingRequests_plural => 'solicitudes pendientes';

  @override
  String get newServiceRequests =>
      'Las nuevas solicitudes de servicio aparecerán aquí cuando los clientes le reserven.';

  @override
  String get quickReplies =>
      'Las respuestas rápidas le ayudan a convertir más solicitudes en trabajos confirmados.';

  @override
  String get dispatchMatch => 'Coincidencia de envío';

  @override
  String get newOffer => 'Nueva oferta disponible';

  @override
  String get accept => 'Aceptar';

  @override
  String get decline => 'Rechazar';

  @override
  String get offerAccepted => 'Oferta aceptada — trabajo confirmado';

  @override
  String get offerDeclined => 'Oferta rechazada';

  @override
  String get acceptFailed => 'Error al aceptar la oferta';

  @override
  String get declineFailed => 'Error al rechazar la oferta';

  @override
  String get dispatchUnavailable => 'Envío no disponible';

  @override
  String get couldNotLoadRequests => 'No se pudieron cargar las solicitudes';

  @override
  String get retry => 'Reintentar';

  @override
  String get noJobRequests => 'Aún no hay solicitudes de trabajo';

  @override
  String get noJobRequestsSubtitle =>
      'Cuando un cliente reserve uno de sus servicios, la solicitud aparecerá aquí para su revisión.';

  @override
  String get jobAccepted => 'Trabajo aceptado exitosamente';

  @override
  String get jobDeclined => 'Trabajo rechazado';

  @override
  String get acceptJobFailed => 'Error al aceptar el trabajo';

  @override
  String get declineJobFailed => 'Error al rechazar el trabajo';

  @override
  String get jobRequests => 'Solicitudes de trabajo';

  @override
  String get jobRequestsSubtitle =>
      'Revise y responda rápidamente a las nuevas reservas de los clientes.';

  @override
  String get timeMaterial => 'TIEMPO-MATERIAL';

  @override
  String get scheduled => 'PROGRAMADO';

  @override
  String get controlYourExperience => 'Controle su experiencia en la app';

  @override
  String get controlYourExperienceSubtitle =>
      'Apariencia, seguridad, notificaciones y soporte, todo en un solo lugar.';
}
