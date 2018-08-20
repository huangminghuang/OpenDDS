find_package(OpenSSL)

ace_requires(OPENSSL_FOUND
             OPENDDS_SECURITY 
             "NOT OPENDDS_SAFETY_PROFILE")

ace_add_lib(OpenDDS_Security
  OUTPUT_NAME OpenDDS_Security
  PACKAGE OpenDDS
  FOLDER OpenDDS/dds/DCPS
  DEFINE_SYMBOL DDSSECURITY_BUILD_DLL
  PUBLIC_INCLUDE_DIRECTORIES ${OPENSSL_INCLUDE_DIR}
  PUBLIC_LINK_LIBRARIES ${OPENSSL_LIBRARIES}
                        OpenDDS_Rtps
                        ACE_XML_Utils
)

ace_target_cxx_sources(OpenDDS_Security
  GLOB_HEADERS
  SOURCE_FILES AccessControlBuiltInImpl.cpp  
               AuthenticationBuiltInImpl.cpp 
               BuiltInPluginLoader.cpp       
               BuiltInPlugins.cpp            
               BuiltInSecurityPluginInst.cpp 
               CommonUtilities.cpp           
               CryptoBuiltInImpl.cpp         
               TokenReader.cpp               
               TokenWriter.cpp
               AccessControl/Governance.cpp
               AccessControl/LocalAccessCredentialData.cpp
               AccessControl/Permissions.cpp
               Authentication/LocalAuthCredentialData.cpp
               SSL/Certificate.cpp
               SSL/DiffieHellman.cpp
               SSL/PrivateKey.cpp
               SSL/SignedDocument.cpp
               SSL/SubjectName.cpp
               SSL/Utils.cpp
)

dds_idl_sources(
    TARGETS OpenDDS_Security
    DDS_IDL_FLAGS -Wb,export_macro=DdsSecurity_Export -Wb,export_include=DdsSecurity_Export.h
    TAO_IDL_FLAGS -Wb,export_macro=DdsSecurity_Export -Wb,export_include=DdsSecurity_Export.h -SS
    IDL_FILES CryptoBuiltIn.idl
)