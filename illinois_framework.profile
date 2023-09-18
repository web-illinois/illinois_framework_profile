<?php

/**
 * @file
 * The illinois_framework profile.
 */

use Drupal\user\RoleInterface;
use Drupal\user\UserInterface;
use Drupal\shortcut\Entity\Shortcut;

/**
 * Implements hook_install_tasks().
 */
function illinois_framework_install_tasks() {
  $tasks = [];

  $tasks['illinois_framework_prepare_administrator'] = [];
  $tasks['illinois_framework_set_front_page'] = [];
  $tasks['illinois_framework_disallow_free_registration'] = [];
  $tasks['illinois_framework_grant_shortcut_access'] = [];
  $tasks['illinois_framework_create_shortcuts'] = [];
  $tasks['illinois_framework_set_default_theme'] = [];
  $tasks['illinois_framework_set_logo'] = [];

  return $tasks;
}

/**
 * Assigns the 'administrator' role to user 1.
 */
function illinois_framework_prepare_administrator() {
  /** @var \Drupal\user\UserInterface $account */
  $account = \Drupal::entityTypeManager()
    ->getStorage('user')
    ->load(1);
  if ($account) {
    $account->addRole('administrator');
    $account->save();
  }
}

/**
 * Sets the front page path to /node.
 */
function illinois_framework_set_front_page() {
  if (Drupal::moduleHandler()->moduleExists('node')) {
    Drupal::configFactory()
      ->getEditable('system.site')
      ->set('page.front', '/node')
      ->save(TRUE);
  }
}

/**
 * Only allows administrators to create new user accounts.
 */
function illinois_framework_disallow_free_registration() {
  Drupal::configFactory()
    ->getEditable('user.settings')
    ->set('register', UserInterface::REGISTER_ADMINISTRATORS_ONLY)
    ->save(TRUE);
}

/**
 * Allows authenticated users to use shortcuts.
 */
function illinois_framework_grant_shortcut_access() {
  if (Drupal::moduleHandler()->moduleExists('shortcut')) {
    user_role_grant_permissions(RoleInterface::AUTHENTICATED_ID, ['access shortcuts']);
  }
}

/**
 * Populate the default shortcut set.
 */
function illinois_framework_create_shortcuts() {
  // We install some menu links, so we have to rebuild the router, to ensure the
  // menu links are valid.
  \Drupal::service('router.builder')->rebuildIfNeeded();

  if (Drupal::moduleHandler()->moduleExists('shortcut')) {
    // Populate the default shortcut set.
    $shortcut = Shortcut::create([
        'shortcut_set' => 'default',
        'title' => t('Add content'),
        'weight' => -20,
        'link' => ['uri' => 'internal:/node/add'],
    ]);
    $shortcut->save();

    $shortcut = Shortcut::create([
        'shortcut_set' => 'default',
        'title' => t('All content'),
        'weight' => -19,
        'link' => ['uri' => 'internal:/admin/content'],
    ]);
    $shortcut->save();
  }
}

/**
 * Sets the default and administration themes.
 */
function illinois_framework_set_default_theme() {
  Drupal::configFactory()
    ->getEditable('system.theme')
    ->set('default', 'illinois_framework_theme')
    ->set('admin', 'gin')
    ->save(TRUE);

  // Use the admin theme for creating content.
  if (Drupal::moduleHandler()->moduleExists('node')) {
    Drupal::configFactory()
      ->getEditable('node.settings')
      ->set('use_admin_theme', TRUE)
      ->save(TRUE);
  }
}

/**
 * Set the path to the logo, favicon and README file based on install directory.
 */
function illinois_framework_set_logo() {
  $illinois_framework_path = Drupal\Core\Extension\ExtensionPathResolver::getPath('profile', 'illinois_framework');

  Drupal::configFactory()
    ->getEditable('system.theme.global')
    ->set('logo', [
      'path' => $illinois_framework_path . '/illinois_logo.png',
      'url' => '',
      'use_default' => FALSE,
    ])
    ->set('favicon', [
      'mimetype' => 'image/vnd.microsoft.icon',
      'path' => $illinois_framework_path . '/favicon.ico',
      'url' => '',
      'use_default' => FALSE,
    ])
    ->save(TRUE);
}

/**
 * Set the default admin theme to gin
 */
function illinois_framework_update_9002() {
  // Install and set the admin theme to gin
  \Drupal::service('theme_installer')->install(['gin']);
  Drupal::configFactory()
    ->getEditable('system.theme')
    ->set('admin', 'gin')
    ->save(TRUE);

  // Install the gin_toolbar module
  \Drupal::service('module_installer')->install(['gin_toolbar']);
}

/**
 * Enable the bootstrap5 theme as part of the 3.0 release of the ILFW
 */
function illinois_framework_update_9003() {
  \Drupal::service('theme_installer')->install(['bootstrap5']);
}
