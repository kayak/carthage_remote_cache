class ShellWrapper
  # @return
  #   Xcode 9.2
  #   Build version 9C40b
  def xcodebuild_version
    sh("xcodebuild -version")
  end

  # @return
  #   Apple Swift version 4.0.3 (swiftlang-900.0.74.1 clang-900.0.39.2)
  #   Target: x86_64-apple-macosx10.9
  def swift_version
    sh("swift -version")
  end

  # @return
  #   UUID: 69BD256A-C658-3D96-9D5A-FF4B8ED6900C (i386) Carthage/Build/iOS/Attributions.framework/Attributions
  #   UUID: BA1067DB-915A-3DA2-AC16-8C2F2947095E (x86_64) Carthage/Build/iOS/Attributions.framework/Attributions
  #   UUID: DF7DA357-FF4B-3BB8-BCC3-7CE5B97E52E0 (armv7) Carthage/Build/iOS/Attributions.framework/Attributions
  #   UUID: 824033E6-7ABA-3568-A90B-6AF6AFAF4BB9 (arm64) Carthage/Build/iOS/Attributions.framework/Attributions
  def dwarfdump(path)
    sh("/usr/bin/xcrun dwarfdump --uuid \"#{path}\"")
  end

  def archive(input_paths, output_path)
    sh("zip -r #{quote output_path} #{quote input_paths}")
  end

  def unpack(archive_path)
    sh("unzip -o #{quote archive_path}")
  end
end
